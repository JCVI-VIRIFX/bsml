#! /local/perl/bin/perl

my $file = $ARGV[0];
my $dtd = $ARGV[1];

if( $dtd )
{
    $dtd =~ s/\//\\\//g;
    system "sed -e \'s/<\\!DOCTYPE Bsml PUBLIC \"-\\/\\/EBI\\/\\/Labbook, Inc. BSML DTD\\/\\/EN\" \"http:\\/\\/www.labbook.com\\/dtd\\/bsml3_1.dtd\">/<\\!DOCTYPE Bsml SYSTEM \"$dtd\">/\' $file | ./Xerces-xsdValid";
}

else
{
    system "more $file | ./Xerces-xsdValid";
}

