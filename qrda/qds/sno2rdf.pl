#!/usr/bin/perl -w

print "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
print "<snomed>\n";
while(<STDIN>)
{
    my($line) = $_;
    chomp($line);
    #print "$line\n";
    #if ($line =~ /(\d+)\t(\d+).((\w| |\(|\))+)\t(\w+)\t/)
    #if ($line =~ m/(^\t+)\t(^\t+)\t(^\t+)\t(^\t+)\t/)
    {
    print "<e c=\"" . $1 . "\" n=\"" . $3 . "\" \/>" . "\n";
    }
}
print "</snomed>\n";
