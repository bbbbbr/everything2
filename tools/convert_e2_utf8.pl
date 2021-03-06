#!/usr/bin/perl -w

use strict;
use Carp;
use DBI;
use Encode::Encoder;

my $dbh = DBI->connect("DBI:mysql:everything:localhost;mysql_enable_utf8=1", "everyuser", "", {AutoCommit => 1});

my $reference_tables =
{
	"node" => "title",
	"message" => "msgtext",
	"document" => "doctext",
};


sub make_count_table
{
	my ($flavor, $table, $column) = @_;

	if(exists($reference_tables->{$table}) and $reference_tables->{$table} eq $column)
	{
		my $count_table = "_".$flavor."_".$table."_".$column."_length";
		sql_verbose_do("DROP TABLE IF EXISTS $count_table");
		sql_verbose_do("CREATE TABLE $count_table (id INT NOT NULL PRIMARY KEY, ".$flavor."length INT)");
		sql_verbose_do("INSERT INTO $count_table SELECT $table"."_id as id, CHAR_LENGTH($column) AS ".$flavor."length FROM $table");
	}
}

sub convert_table_column
{
	my ($table, $column, $definition, $pre, $post) = @_;

	make_count_table("latin1",$table,$column);

	my $latin1_check_csr = $dbh->prepare("SELECT    COLUMN_NAME,   TABLE_NAME,   CHARACTER_SET_NAME,   COLUMN_TYPE,   COLLATION_NAME FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = 'everything' and CHARACTER_SET_NAME='latin1' and TABLE_NAME='$table' and COLUMN_NAME='$column'");
	$latin1_check_csr->execute();

	if(my $row = $latin1_check_csr->fetchrow_arrayref())
	{
		print STDERR "Converting $table.$column\n";
	}else{
		print STDERR "Not converting $table.$column, not latin1\n";
		return;
	}

	# Fix the encoding
	sql_verbose_do("ALTER TABLE $table MODIFY $column $definition character set utf8 COLLATE utf8_unicode_ci");
	#sql_verbose_do("UPDATE $table SET $column=CONVERT(CONVERT(BINARY $column using latin1) using utf8)"); 
	sql_verbose_do("ALTER TABLE $table DEFAULT character set utf8 COLLATE utf8_unicode_ci");

	make_count_table("utf8",$table,$column);
}

sub explain_table
{
	my ($table) = @_;
	my $result;

	my $explain_csr = $dbh->prepare("EXPLAIN $table");
	$explain_csr->execute();
	while(my $row = $explain_csr->fetchrow_arrayref())
	{
		$result->{$row->[0]} = $result->{$row->[1]};
	}

	return $result;
}

sub sql_verbose_do
{
	my ($cmd) = @_;

	print STDERR localtime()."\n";
	print STDERR "$cmd"."\n";
	return $dbh->do($cmd);
}

my $latin1_search = $dbh->prepare("SELECT TABLE_NAME, COLUMN_NAME, COLUMN_TYPE FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = 'everything' and CHARACTER_SET_NAME='latin1'");

$latin1_search->execute();

while (my $row = $latin1_search->fetchrow_arrayref())
{
	my ($latin1_table, $latin1_column, $latin1_type) = @$row;
	convert_table_column($latin1_table, $latin1_column, $latin1_type);
}

sql_verbose_do("ALTER DATABASE everything DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci");
