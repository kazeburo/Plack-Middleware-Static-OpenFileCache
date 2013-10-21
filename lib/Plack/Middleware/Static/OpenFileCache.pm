package Plack::Middleware::Static::OpenFileCache;

use 5.008005;
use strict;
use warnings;
use parent qw/Plack::Middleware::Static/;
use Plack::Util::Accessor qw(max expires cache_errors _cache_lru);
use Cache::LRU::WithExpires;

our $VERSION = "0.01";

sub prepare_app {
    my $self = shift;
    my $max = $self->max;
    $max = 100 unless defined $max;
    $self->expires(60) unless defined $self->expires;
    $self->_cache_lru(Cache::LRU::WithExpires->new(size => $max));
}

sub _handle_static {
    my($self, $env) = @_;
    my $path = $env->{PATH_INFO};
    my $cache = $self->_cache_lru;
    my $res = $cache->get($path);
    if ( $res ) {
        if ( ref $res->[2] ne 'ARRAY' ) {
            seek($res->[2],0,0);
        }
        return $res;
    }
    $res = $self->SUPER::_handle_static($env);
    return unless defined $res;
    if ( ref $res->[2] ne 'ARRAY' ) {
        my $io_path = $res->[2]->path;
        bless $res->[2], 'Plack::Middleware::Static::OpenFileCache::IOWithPath';
        $res->[2]->path($io_path);
    }
    if ( $res->[0] =~ m!^2! or $self->cache_errors ) {
        $cache->set($path, $res, $self->expires);
    }
    $res;
}

package Plack::Middleware::Static::OpenFileCache::IOWithPath;
use parent qw(IO::Handle);

sub path {
    my $self = shift;
    if (@_) {
        ${*$self}{+__PACKAGE__} = shift;
    }
    ${*$self}{+__PACKAGE__};
}

sub close {}

1;
__END__

=encoding utf-8

=head1 NAME

Plack::Middleware::Static::OpenFileCache - It's new $module

=head1 SYNOPSIS

    use Plack::Middleware::Static::OpenFileCache;

=head1 DESCRIPTION

Plack::Middleware::Static::OpenFileCache is ...

=head1 LICENSE

Copyright (C) Masahiro Nagano.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Masahiro Nagano E<lt>kazeburo@gmail.comE<gt>

=cut

