#!/usr/bin/perl -w
use strict;
use Bio::Tools::IUPAC;
my %rev_alleles = Bio::Tools::IUPAC->iupac_rev_iub();
my @strains;
while(<>) {
    if( /^\#CHROM/ ) {
	@strains = split;
	splice(@strains,0,9);
	print join("\t", qw(CHROM POS REF), @strains),"\n";
	next;
    } elsif(/^\#/) { next }
    else {
	next if /INDEL;/;
	my ($chrom,$pos,$id,$ref,$alt,undef,@genotypes) = split;
	my @site_alleles = ($ref,split(/,/,$alt));
	my @row = ($chrom,$pos,$ref);
	for my $strain ( reverse @strains ) {
	    my ($genotype,$PL,$GQ) = split(/:/,pop @genotypes);
	    my %seen;
	    my $alleles = join("",sort grep { ! $seen{$_}++ } 
			  map { $site_alleles[$_] } 
			  split(/\//,$genotype));
	   
	    push @row, exists $rev_alleles{$alleles} ? $rev_alleles{$alleles} : warn "cannot find $alleles for $chrom $pos\n";
	}
	print join("\t", @row),"\n";
    }
}
