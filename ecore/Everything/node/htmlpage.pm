#!/usr/bin/perl -w

use strict;
use lib qw(lib);
package Everything::node::htmlpage;
use base qw(Everything::node::node);

sub node_to_xml
{
	my ($this, $NODE) = @_;

	# Strip old windows line endings
	$NODE->{page} = $this->_clean_code($NODE->{page});
	return $this->SUPER::node_to_xml($NODE);
}

1;
