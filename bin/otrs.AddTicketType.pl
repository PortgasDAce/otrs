#!/usr/bin/perl
# --
# bin/otrs.AddTicketType.pl - add new Ticket Types
# Copyright (C) 2001-2014 OTRS AG, http://otrs.com/
# --
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU AFFERO General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA
# or see http://www.gnu.org/licenses/agpl.txt.
# --

use strict;
use warnings;

use File::Basename;
use FindBin qw($RealBin);
use lib dirname($RealBin);
use lib dirname($RealBin) . '/Kernel/cpan-lib';
use lib dirname($RealBin) . '/Custom';

use Kernel::System::ObjectManager;

# create common objects
local $Kernel::OM = Kernel::System::ObjectManager->new(
    LogObject => {
        LogPrefix => 'OTRS-otrs.TicketType',
    },
);
my %CommonObject = $Kernel::OM->ObjectHash(
    Objects => [qw(ConfigObject EncodeObject MainObject DBObject TypeObject)],
);

my %Param;
my %Options;

use Getopt::Std;
getopts( 'n:h', \%Options );

if ( $Options{h} ) {
    print STDERR "Usage: $FindBin::Script -n <Type>\n";
    exit;
}

if ( !$Options{n} ) {
    print STDERR "ERROR: Need -n <Type>\n";
    exit 1;
}

# user id of the person adding the record
$Param{UserID} = '1';

# Validrecord
$Param{ValidID} = '1';
$Param{Name} = $Options{n} || '';

if ( my $RID = $CommonObject{TypeObject}->TypeAdd(%Param) ) {
    print "Ticket type '$Options{n}' added. Type id is '$RID'\n";
}
else {
    print STDERR "ERROR: Can't add type\n";
}

exit(0);
