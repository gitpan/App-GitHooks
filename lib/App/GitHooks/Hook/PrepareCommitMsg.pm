package App::GitHooks::Hook::PrepareCommitMsg;

use strict;
use warnings;

# Inherit from the base Hook class.
use base 'App::GitHooks::Hook';

# External dependencies.
use Carp;
use Data::Dumper;
use File::Slurp ();

# Internal dependencies.
use App::GitHooks::CommitMessage;
use App::GitHooks::Constants qw( :PLUGIN_RETURN_CODES :HOOK_EXIT_CODES );


=head1 NAME

App::GitHooks::Hook::CommitMsg - Handler for commit-msg hook.


=head1 VERSION

Version 1.1.5

=cut

our $VERSION = '1.1.5';


=head1 METHODS

=head2 run()

Run the hook handler and return an exit status to pass to git.

	my $exit_status = App::GitHooks::Hook::CommitMsg->run(
		app => $app,
	);

Arguments:

=over 4

=item * app I<(mandatory)>

An App::GitHooks object.

=back

=cut

sub run
{
	my ( $class, %args ) = @_;
	my $app = delete( $args{'app'} );
	croak 'Unknown argument(s): ' . join( ', ', keys %args )
		if scalar( keys %args ) != 0;

	# Check parameters.
	croak "The 'app' argument is mandatory"
		if !Data::Validate::Type::is_instance( $app, class => 'App::GitHooks' );

	# Retrieve the commit message.
	my $command_line_arguments = $app->get_command_line_arguments();
	my $commit_message_file = $command_line_arguments->[0];
	my $commit_message = App::GitHooks::CommitMessage->new(
		message => File::Slurp::read_file( $commit_message_file ) // '',
		app     => $app,
	);

	# Find and run all the plugins that support the prepare-commit-msg hook.
	my $tests_success = 1;
	my $plugins = $app->get_plugins( 'prepare-commit-msg' );
	foreach my $plugin ( @$plugins )
	{
		my $check_result = $plugin->run_prepare_commit_msg(
			app            => $app,
			commit_message => $commit_message,
		);
		$tests_success = 0
			if $check_result == $PLUGIN_RETURN_FAILED;
	}

	# If the commit message was modified above, we need to overwrite the file.
	if ( $commit_message->has_changed() )
	{
		my $terminal = $app->get_terminal();
		my $terminal_encoding = $terminal->get_encoding();
		my $filehandle_encoding = $terminal->is_utf8()
			? ":encoding($terminal_encoding)"
			: '';

		# Note: File::Slurp doesn't support utf-8, unfortunately.
		open( my $fh, ">$filehandle_encoding", $commit_message_file )
			|| croak "Failed to open $commit_message_file with encoding '$filehandle_encoding': $!";
		print $fh $commit_message->get_message();
		close( $fh );
	}

	# .git/COMMIT-MSG-CHECKS is a file we use to track if the pre-commit hook has
	# run, as opposed to being skipped with --no-verify. Since pre-commit can be
	# skipped, but prepare-commit-msg cannot, plugins can use the presence of
	# that file to determine if some optional processing should be performed in
	# the prepare-commit-msg phase. For example, you may want to add a warning
	# indicating that --no-verify was used. Note however that the githooks man
	# page says "it should not be used as replacement for pre-commit hook".
	#
	# And since we're done with prepare-commit-msg checks now, we can safely
	# remove the file.
	unlink( '.git/COMMIT-MSG-CHECKS' );

	return $tests_success
		? $HOOK_EXIT_SUCCESS
		: $HOOK_EXIT_FAILURE;
}


=head1 BUGS

Please report any bugs or feature requests through the web interface at
L<https://github.com/guillaumeaubert/App-GitHooks/issues/new>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

	perldoc App::GitHooks::Hook::PrepareCommitMsg


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
