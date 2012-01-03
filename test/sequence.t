#! /usr/bin/perl
################################################################################
## taskwarrior - a command line task list manager.
##
## Copyright 2006-2012, Paul Beckingham, Federico Hernandez.
##
## Permission is hereby granted, free of charge, to any person obtaining a copy
## of this software and associated documentation files (the "Software"), to deal
## in the Software without restriction, including without limitation the rights
## to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
## copies of the Software, and to permit persons to whom the Software is
## furnished to do so, subject to the following conditions:
##
## The above copyright notice and this permission notice shall be included
## in all copies or substantial portions of the Software.
##
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
## OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
## FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
## THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
## LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
## OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
## SOFTWARE.
##
## http://www.opensource.org/licenses/mit-license.php
##
################################################################################

use strict;
use warnings;
use Test::More tests => 26;

# Create the rc file.
if (open my $fh, '>', 'seq.rc')
{
  print $fh "data.location=.\n",
            "confirmation=off\n";
  close $fh;
  ok (-r 'seq.rc', 'Created seq.rc');
}

# Test sequences in done/undo
qx{../src/task rc:seq.rc add one mississippi};
qx{../src/task rc:seq.rc add two mississippi};
qx{../src/task rc:seq.rc 1,2 do};
my $output = qx{../src/task rc:seq.rc info 1};
like ($output, qr/Status\s+Completed/, 'sequence do 1');
$output = qx{../src/task rc:seq.rc info 2};
like ($output, qr/Status\s+Completed/, 'sequence do 2');
qx{../src/task rc:seq.rc undo};
qx{../src/task rc:seq.rc undo};
$output = qx{../src/task rc:seq.rc info 1};
like ($output, qr/Status\s+Pending/, 'sequence undo 1');
$output = qx{../src/task rc:seq.rc info 2};
like ($output, qr/Status\s+Pending/, 'sequence undo 2');

# Test sequences in delete/undelete
qx{../src/task rc:seq.rc 1,2 delete};
$output = qx{../src/task rc:seq.rc info 1};
like ($output, qr/Status\s+Deleted/, 'sequence delete 1');
$output = qx{../src/task rc:seq.rc info 2};
like ($output, qr/Status\s+Deleted/, 'sequence delete 2');
qx{../src/task rc:seq.rc undo};
qx{../src/task rc:seq.rc undo};
$output = qx{../src/task rc:seq.rc info 1};
like ($output, qr/Status\s+Pending/, 'sequence undo 1');
$output = qx{../src/task rc:seq.rc info 2};
like ($output, qr/Status\s+Pending/, 'sequence undo 2');

# Test sequences in start/stop
qx{../src/task rc:seq.rc 1,2 start};
$output = qx{../src/task rc:seq.rc info 1};
like ($output, qr/Start/, 'sequence start 1');
$output = qx{../src/task rc:seq.rc info 2};
like ($output, qr/Start/, 'sequence start 2');
qx{../src/task rc:seq.rc 1,2 stop};
$output = qx{../src/task rc:seq.rc info 1};
like ($output, qr/Start\sdeleted/, 'sequence stop 1');
$output = qx{../src/task rc:seq.rc info 2};
like ($output, qr/Start\sdeleted/, 'sequence stop 2');

# Test sequences in modify
qx{../src/task rc:seq.rc 1,2 modify +tag};
$output = qx{../src/task rc:seq.rc info 1};
like ($output, qr/Tags\s+tag/, 'sequence modify 1');
$output = qx{../src/task rc:seq.rc info 2};
like ($output, qr/Tags\s+tag/, 'sequence modify 2');
qx{../src/task rc:seq.rc 1,2 modify -tag};
$output = qx{../src/task rc:seq.rc info 1};
unlike ($output, qr/Tags\s+tag/, 'sequence unmodify 1');
$output = qx{../src/task rc:seq.rc info 2};
unlike ($output, qr/Tags\s+tag/, 'sequence unmodify 2');

# Test sequences in substitutions
qx{../src/task rc:seq.rc 1,2 modify /miss/Miss/};
$output = qx{../src/task rc:seq.rc info 1};
like ($output, qr/Description\s+one Miss/, 'sequence substitution 1');
$output = qx{../src/task rc:seq.rc info 2};
like ($output, qr/Description\s+two Miss/, 'sequence substitution 2');

# Test sequences in info
$output = qx{../src/task rc:seq.rc info 1,2};
like ($output, qr/Description\s+one Miss/, 'sequence info 1');
like ($output, qr/Description\s+two Miss/, 'sequence info 2');

# Test sequences in duplicate
qx{../src/task rc:seq.rc 1,2 duplicate pri:H};
$output = qx{../src/task rc:seq.rc info 3};
like ($output, qr/Priority\s+H/, 'sequence duplicate 1');
$output = qx{../src/task rc:seq.rc info 4};
like ($output, qr/Priority\s+H/, 'sequence duplicate 2');

# Test sequences in annotate
qx{../src/task rc:seq.rc 1,2 annotate note};
$output = qx{../src/task rc:seq.rc info 1};
like ($output, qr/\d+\/\d+\/\d+ note/, 'sequence 1 annotate');
$output = qx{../src/task rc:seq.rc info 2};
like ($output, qr/\d+\/\d+\/\d+ note/, 'sequence 2 annotate');

# Cleanup.
unlink qw(pending.data completed.data undo.data backlog.data synch.key seq.rc);
ok (! -r 'pending.data'   &&
    ! -r 'completed.data' &&
    ! -r 'undo.data'      &&
    ! -r 'backlog.data'   &&
    ! -r 'synch.key'      &&
    ! -r 'seq.rc', 'Cleanup');

exit 0;

