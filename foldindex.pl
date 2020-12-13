#!/usr/bin/perl

use strict;
use warnings;
use LWP::Simple;

my $inFile = shift; 
open (IN, "$inFile");

# By default Perl pulls in chunks of text up to a newline (\n) character; newline is
# the default Input Record Separator. You can change the Input Record Separator by
# using the special variable "$/". When dealing with FASTA files I normally change the
# Input Record Separator to ">" which allows your script to take in a full, multiline
# FASTA record at once.

$/ = ">";

# At each input your script will now read text up to and including the first ">" it encounters.
# This means you have to deal with the first ">" at the begining of the file as a special case.

my $junk = <IN>; # Discard the ">" at the begining of the file

# Now read through your input file one sequence record at a time. Each input record will be a
# multiline FASTA entry.

#	Declare multiple variables

while ( my $record = <IN> ) {
	chomp $record; # Remove the ">" from the end of $record, and realize that the ">" is already gone from the begining of the record
	
# 	Now split up your record into its definition line and sequence lines using split at each newline.
# 	The definition will be stored in a scalar variable and each sequence line as an
# 	element of an array.
	
	my ($defLine, @seqLines) = split /\n/, $record;
	
#	Join the individual sequence lines into one single sequence and store in a scalar variable.
	
	my $seq = join('',@seqLines); # Concatenates all elements of the @seqLines array into a single string.
	my $name = $defLine; # Add your definition; remember the ">" has already been removed. Remember to print a newline.
	my $len = length($seq); # Add the sequence length

#	Calculate foldindex

	my $sequence = qq{$seq};
	my $findex = getFoldIndex($sequence);
	sub getFoldIndex {
		my($aa) = @_;
		$aa =~ s/\W//g;
		my $content = get("http://fold.weizmann.ac.il/fldbin/findex?m=xml&sq=$aa");
		my ($findex) = $content =~ /<findex>([\-\.\d]+)<\/findex>/;
		return $findex;
		}
	
	my @items = ($name, $len, $seq, $findex);
	print join("\t", @items) . "\n";

}

