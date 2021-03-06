#!/usr/bin/perl -w

use strict;
use Everything;
use Net::Amazon::S3;
package Everything::S3;

sub new
{
	my ($class, $s3type) = @_;
	
	return if not defined $s3type;
	my $this = {};
	if(exists($Everything::CONF->{s3}->{$s3type}))
	{
		foreach my $value (qw/bucket access_key_id secret_access_key/)
		{
			if(exists($Everything::CONF->{s3}->{$s3type}->{$value}))
			{
				$this->{$value} = $Everything::CONF->{s3}->{$s3type}->{$value};
			}else{
				return undef;
			}
		}
	}else{
		return undef;
	}

	$this->{s3} = Net::Amazon::S3->new(
	{   
		aws_access_key_id     => $this->{access_key_id},
		aws_secret_access_key => $this->{secret_access_key},
		retry                 => 1,
	});

	return unless defined($this->{s3});
	$this->{bucket} = $this->{s3}->bucket($this->{bucket});

	return bless $this,$class;
}

sub upload_data
{
	my ($this, $name, $data, $properties) = @_;
	return $this->{bucket}->add_key($name, $data, $properties);
}

sub upload_file
{
	my ($this, $name, $filename, $properties) = @_;
	return $this->{bucket}->add_key_filename($name, $filename, $properties);
}

sub delete
{
	my ($this, $filename) = @_;
}

1;
