use strict;
use warnings;
use inc::Module::Install;

name 'Search-GIN';
all_from 'lib/Search/GIN/Core.pm';

build_requires 'Test::More';

WriteAll();
