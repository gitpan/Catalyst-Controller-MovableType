package Catalyst::Controller::MovableType;
use Moose;
BEGIN { extends 'Catalyst::Controller::WrapCGI'; }
use utf8;
use namespace::autoclean;

our $VERSION = 0.001;

has 'perl' => (is => 'rw', default => 'perl');

has 'mt_home' => (is => 'rw'); # /my/app/root/mt/

sub run_mt_script :Path {
    my ($self, $c, $cgi_script) = @_;

    my %mt_scripts
        = map +($_ => 1),
        qw( mt-add-notify.cgi
            mt-atom.cgi
            mt.cgi
            mt-comments.cgi
            mt-feed.cgi
            mt-ftsearch.cgi
            mt-search.cgi
            mt-tb.cgi
            mt-testbg.cgi
            mt-upgrade.cgi
            mt-wizard.cgi
            mt-xmlrpc.cgi
        ) # mt-config.cgi intentionally left out
    ;

    # http://www.movabletype.org/documentation/installation/install-movable-type.html#start-blogging states:
    # Warning: because the mt-check.cgi script displays server details which could be useful to a hacker, it
    # is recommended that this script be removed or renamed.
    #
    # Allow it only in debug mode.
    $mt_scripts{'mt_check.cgi'} = 1 if ($c->debug());

    $self->not_found() unless ($mt_scripts{$cgi_script});

    $ENV{MT_HOME} = $self->mt_home;

    $self->cgi_to_response($c, sub { 
        system($self->perl, $self->mt_home.$cgi_script);
    });
}

sub not_found :Private {
    my ($self, $c) = @_;
    $c->response->status(404);
    $c->response->body('Not found!');
    $c->detach();
}
 
1;

__END__

=head1 NAME

Catalyst::Controller::MovableType - Run Movable Type through Catalyst

=head1 SYNOPSIS

package MyApp::Controller::Mt;

use Moose;
BEGIN {extends 'Catalyst::Controller::MT'; }
use utf8;

1;

=head1 INSTALLATION

Install Movable Type by extracting the zip into your template root directory.
Move mt-static to root/static/mt, and configure Movable Type accordingly.

=head1 DESCRIPTION

Runs Movable Type 5 through Catalyst.
Download Movable Type 5 from http://www.movabletype.org/

=head1 METHODS

=head2 run_mt_script

Runs the requested Movable Type .cgi script transparently with cgi_to_response.

=head2 not_found

Sets the response to a simple 404 Not found page. You can override this method
with your own.

=head1 BUGS

None known.

=head1 SEE ALSO

L<Catalyst::Controller::WrapCGI>

=head1 AUTHOR

Oskari 'Okko' Ojala <perl@okko.net>

=head1 CONTRIBUTORS

Matt S. Trout <mst@shadowcatsystems.co.uk>

=head1 COPYRIGHT & LICENSE

Copyright 2010 the above author(s).

This sofware is free software, and is licensed under the same terms as Perl itself.

=cut

