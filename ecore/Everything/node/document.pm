#!/usr/bin/perl -w

use strict;
use lib qw(lib);
package Everything::node::document;
use base qw(Everything::node::node);

sub node_to_xml
{
	my ($this, $NODE) = @_;

	# Strip old windows line endings
	$NODE->{doctext} = $this->_clean_code($NODE->{doctext});
	return $this->SUPER::node_to_xml($NODE);
}

1;