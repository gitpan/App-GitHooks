package App::GitHooks::Hook;

use strict;
use warnings;

# External dependencies.
use Carp;

# Internal dependencies.
use App::GitHooks::Constants qw( :HOOK_EXIT_CODES :PLUGIN_RETURN_CODES );


=head1 NAME

App::GitHooks::Hook - Base class for all git hook handlers.


=head1 VERSION

Version 1.1.5

=cut

our $VERSION = '1.1.5';


=head1 METHODS

=head2 run()

Run the hook handler and return an exit status to pass to git.

	my $exit_status = App::GitHooks::Hook->run(
		app => $app,
	);

Arguments:

=over 4

=item * app I<(mandatory)>

An L<App::GitHooks> object.

=back

=cut

sub run
{
	my ( $class, %args ) = @_;
	my $app = $args{'app'};

	# Find all the plugins that are applicable for this hook.
	my $plugins = $app->get_plugins( $app->get_hook_name() );

	# Run all the plugins.
	my $has_errors = 0;
	foreach my $plugin ( @$plugins )
	{
		my $method = 'run_' . $app->get_hook_name();

		my $return_code = $plugin->$method(
			app => $app,
		);
		$has_errors = 1
			if $return_code == $PLUGIN_RETURN_FAILED;
	}

	# Return an exit code for Git.
	return $has_errors
		? $HOOK_EXIT_FAILURE
		: $HOOK_EXIT_SUCCESS;
}


=head1 BUGS

Please report any bugs or feature requests through the web interface at
L<https://github.com/guillaumeaubert/App-GitHooks/issues/new>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

	perldoc App::GitHooks::Hook


You can also look for information at:

=over

=item * GitHub's request tracker

L<https://github.com/guillaumeaubert/App-GitHooks/issues>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/app-githooks>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/app-githooks>

=item * MetaCPAN

L<https://metacpan.org/release/App-GitHooks>

=back


=head1 AUTHOR

L<Guillaume Aubert|https://metacpan.org/author/AUBERTG>,
C<< <aubertg at cpan.org> >>.


=head1 COPYRIGHT & LICENSE

Copyright 2013-2014 Guillaume Aubert.

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License version 3 as published by the Free
Software Foundation.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program. If not, see http://www.gnu.org/licenses/

=cut

1;
