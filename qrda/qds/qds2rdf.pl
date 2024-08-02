#!/usr/bin/perl -w
print "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
print "<rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\"\n";
print "  xmlns:qds=\"http://cms.gov/pqri/qds/\">\n";
while(<STDIN>)
{
    my($line) = $_;
    chomp($line);
    chop($line);
    $line =~ s/\"//g;
    $line =~ s/\&/\&amp;/g;
    $line =~ s/\</\&lt;/g;
    $line =~ s/\>/\&gt;/g;
    $line =~ s/\'/\&apos;/g;
    $_ = $line;
    push @gpl1, split(/\|/);
    #print "$_\n" for @gpl1;
    my ($NQFid, $name, $QDSid, $concept, $cat, $QDSdt, $conceptid, $taxonomy, $taxonomyver, $codestr, $QDSattr) = @gpl1;
    if ($NQFid ne "NQF_id")
    {
	$_ = $codestr;
	if ($codestr) {push @codes, split(/\,/)};
	$_ =~ s/^ +//g for @codes;
	#print "$name $_ " for @codes;
	#print "\n";
	if ($QDSid)
	{
	    print "<rdf:Description rdf:about=\"";
	    print "/$QDSid\">\n";

	    print "<qds:NQF_id>$NQFid</qds:NQF_id>\n";
	    print "<qds:measure_name>$name</qds:measure_name>\n";
	    print "<qds:QDS_id>$QDSid</qds:QDS_id>\n";
	    print "<qds:standard_concept>$concept</qds:standard_concept>\n";
	    print "<qds:standard_category>$cat</qds:standard_category>\n";
	    print "<qds:QDS_data_type>$QDSdt</qds:QDS_data_type>\n";
	    print "<qds:standard_concept_id>$conceptid</qds:standard_concept_id>\n";
	    if ($taxonomy) {
    	    print "<qds:standard_taxonomy>$taxonomy</qds:standard_taxonomy>\n";
	    }
	    if ($taxonomyver) {
	    print "<qds:standard_taxonomy_version>$taxonomyver</qds:standard_taxonomy_version>\n";
	    }
	    if ($QDSattr)
	    {
	    print "<qds:QDS_datatype_specific_attributes>$QDSattr</qds:QDS_datatype_specific_attributes>\n";
	    }
	    if ($codestr) 
	    {
		print "<qds:standard_code_list>$_</qds:standard_code_list>\n" for @codes;
	    }
	    print "</rdf:Description>\n";
	}
    }
    @gpl1 = ();
    @codes = ();
}
print "</rdf:RDF>\n";
