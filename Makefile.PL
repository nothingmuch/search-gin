#!/usr/bin/perl -w

use strict;

use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'Search::GIN',
    VERSION_FROM => 'lib/Search/GIN.pm',
    INSTALLDIRS  => 'site',
    SIGN         => 1,
    PL_FILES     => { },
    PREREQ_PM    => {
        'Moose' => 0,
        'MooseX::Types::Path::Class' => 0,
        'MooseX::Types::Set::Object' => 0,
        'namespace::clean' => '0.08',
        'Data::Stream::Bulk' => "0.03",
        'Scope::Guard' => 0,
        'Set::Object' => 0,
        'Test::use::ok' => 0,
        'Test::More' => 0,
        'Test::TempDir' => 0,
        'MRO::Compat' => 0,
    },
);
