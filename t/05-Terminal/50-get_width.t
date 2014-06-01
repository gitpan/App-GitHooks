#!perl

use strict;
use warnings;

use App::GitHooks::Terminal;
use Test::Exception;
use Test::FailWarnings -allow_deps => 1;
use Test::More tests => 5;
use Test::Type;


can_ok(
	'App::GitHooks::Terminal',
	'get_width',
);

ok(
	my $terminal = App::GitHooks::Terminal->new(),
	'Instantiate a new object.',
);

ok(
	defined(
		my $is_interactive = $terminal->is_interactive()
	),
	'Determine if the terminal is interactive.',
);

my $width;
lives_ok(
	sub
	{
		$width = $terminal->get_width();
	},
	'Retrieve the terminal width.',
);

if ( $is_interactive )
{
	ok(
		defined( $width ),
		'The terminal width is defined.',
	);
}
else
{
	ok(
		!defined( $width ),
		'The terminal width is not defined.',
	);
}