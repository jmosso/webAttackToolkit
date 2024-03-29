#!/usr/bin/perl

# Prueba de uso Aho-Corasick 1.0
# 28/1/2008
# Juan Manuel Ramon (jmanuel@bacchuss.com.ar)

use Algorithm::AhoCorasick qw(find_all);



require 'getopts.pl';
# require destination and rule file or help

#le agrego el modificador t para abrir el archivo a analizar "target"

Getopts('h:f:t:d:x');

if ($opt_h) {
die "Usage $0 -f <rule file> [-t <target file> || -d <target dir> ] [options]\
\t-x debug\tTurn on debugging information.\
\t-h help\t\tDuh? This is it.\n";
}

my $KB = $opt_f;
my $data_file = $opt_t;
my $data_dir = $opt_d;
#my @keywords = ("pia", "jmanuel");

my @rulez = add_rules($opt_f);

sub add_rules
{
   my ($file) = @_;
   my @rules;

   open(RULES,$file) || die "No es posible abrir el archivo (KB): $file!\n";
   my @lines = <RULES>;

# en @lines tengo todo el contenido del archivo de reglas
   close (RULES);
   foreach my $line (@lines) {
      chomp ($line);

if ($line =~ /^include (.*)$/) {
          if ($opt_x) { print "Agregando include de $1\n";}
          my @line_rules = add_rules($1);
          push (@rules,@line_rules);
      }
      else {push (@rules,$line);}
   }
   return (@rules);
}

# EN EL ARRAY RULES TENGO TODAS LAS REGLAS DEL ARCHIVO (-F)

my $ind_rules = 0;
my $patrones = 0;

foreach $rule (@rulez) 
{

if ($rule =~ /^\s*#/ || $rule eq "\n" ) { next;}

#Descompongo la regla en sus componentes fundamentales as� puedo referenciarlos. El formato es:
# ALERT|LOG PROTO src srcport direction dst dstport
$rule =~ /(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(->|<>|<-)\s+(\S+)\s+(\S+)(.*)$/;

#la variable $rest tiene los keywords de la regla de snort
$rest = $8;
$rest1= $8;
$rest2= $8;

if ($rest =~ /content\s*:\s*"([^"]+).*content\s*:\s*"([^"]+)/)
{
$content=$1;
$content1=$2;
$ind_rules = $ind_rules +1;
$patrones = $patrones +2;

push (@contents, $content);
push (@contents, $content1);

}


elsif ($rest =~ /content\s*:\s*"([^"]+).*/)

{
$content=$1;
$ind_rules = $ind_rules +1;
$patrones = $patrones +1;

push (@contents, $content);

}   
}


$usuario = `whoami`;
$hora = `date +%d.%m.%Y.%R`;
$dir = `pwd`;

my $text = $opt_t;
print "1. $text \n";
open(RULES,$text) || die "No es posible abrir el archivo (KB): $text!\n";
my @lines = <RULES>;
# en @lines tengo todo el contenido del archivo de reglas
foreach my $linexxx (@lines) 
{

#print "2. $line \n";

$found = find_all($linexxx, @contents);
if (!$found) 
	{
    	print "no keywords found\n";
	} 
else 	{
    	foreach $pos (sort keys %$found) 
		{
        	$keywords = join ', ', @{$found->{$pos}};
        	print "$pos: $keywords\n";
    		}
	}


}
close (RULES);




