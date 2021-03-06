# --
# UTF8Range.t - DB unicode tests
# Copyright (C) 2001-2014 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --
use strict;
use warnings;
use vars (qw($Self));
use utf8;

use Kernel::System::XML;
use Kernel::Config;

# create local objects
my $XMLObject = Kernel::System::XML->new( %{$Self} );

# create database for tests
my $XML = '
<Table Name="test_utf8_range">
    <Column Name="test_message" Required="true" Size="255" Type="VARCHAR"/>
</Table>
';
my @XMLARRAY = $XMLObject->XMLParse( String => $XML );
my @SQL = $Self->{DBObject}->SQLProcessor( Database => \@XMLARRAY );
for my $SQL (@SQL) {
    $Self->True(
        $Self->{DBObject}->Do( SQL => $SQL ) || 0,
        "CREATE TABLE ($SQL)",
    );
}

my @Tests = (
    {
        Name => "Ascii / UTF8 1 byte",
        Data => 'aou',
    },
    {
        Name => "UTF8 2 byte",
        Data => 'äöü',
    },
    {
        Name => "UTF8 3 byte",
        Data => 'ऄ',           # DEVANAGARI LETTER SHORT A (e0 a4 84)
    },
    {
        Name                => "UTF8 4 byte",
        Data                => '💩',          # PILE OF POO (f0 9f 92 a9)
        ExpectedDataOnMysql => '�',
    },
);

for my $Test (@Tests) {

    my $Success = $Self->{DBObject}->Do(
        SQL => 'INSERT INTO test_utf8_range ( test_message )'
            . ' VALUES ( ? )',
        Bind => [ \$Test->{Data} ],
    );

    $Self->True(
        $Success,
        "$Test->{Name} - INSERT",
    );

    my $ExpectedData = $Test->{Data};
    if ( $Test->{ExpectedDataOnMysql} && $Self->{DBObject}->{Backend}->{'DB::Type'} eq 'mysql' ) {
        $ExpectedData = $Test->{ExpectedDataOnMysql};
    }

    # Fetch withouth WHERE
    $Self->{DBObject}->Prepare(
        SQL   => 'SELECT test_message FROM test_utf8_range',
        Limit => 1,
    );

    my $RowCount = 0;

    while ( my @Row = $Self->{DBObject}->FetchrowArray() ) {
        $Self->Is(
            $Row[0],
            $ExpectedData,
            "$Test->{Name} - SELECT all",
        );
        $RowCount++;
    }

    $Self->Is(
        $RowCount,
        1,
        "$Test->{Name} - SELECT all row count",
    );

    # Fetch 1 with WHERE
    $Self->{DBObject}->Prepare(
        SQL => '
            SELECT test_message
            FROM test_utf8_range
            WHERE test_message = ?',
        Bind  => [ \$Test->{Data}, ],
        Limit => 1,
    );

    $RowCount = 0;

    while ( my @Row = $Self->{DBObject}->FetchrowArray() ) {
        $Self->Is(
            $Row[0],
            $ExpectedData,
            "$Test->{Name} - SELECT all",
        );
        $RowCount++;
    }

    $Self->Is(
        $RowCount,
        1,
        "$Test->{Name} - SELECT all row count",
    );

    $Success = $Self->{DBObject}->Do(
        SQL => 'DELETE FROM test_utf8_range',
    );

    $Self->True(
        $Success,
        "$Test->{Name} - DELETE",
    );
}

# cleanup
$Self->True(
    $Self->{DBObject}->Do( SQL => 'DROP TABLE test_utf8_range' ) || 0,
    "DROP TABLE",
);

1;
