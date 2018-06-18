#! /usr/bin/perl

use LWP::Simple;
use Switch;
use strict;

sub init_folder {
 my ($actor) = @_;
 `mkdir -p testdoc`;
 my $x = "touch testdoc/$actor";
 my $y = "rm -r testdoc/$actor";
 my $z = "mkdir -p testdoc/$actor";
 print "$x\n"; print `$x`;
 print "$y\n"; print `$y`;
 print "$z\n"; print `$z`;
}

sub write_html_item {
 my ($html, $actor, $t) = @_;
 my $item =
 "   <li><a href=\"testdoc/$actor/$t.html\">$actor/$t.html</li>\n";
 print $html $item;
}

sub read_file {
 my ($path) = @_;
 open my $handle, '<', $path or die "Could not open file: $path";
 my @lines = <$handle>;
 close $handle;
 return @lines;
}

sub contains_pattern {
 my ($line, $pattern, $exit_on_fail) = @_;

 return 1 if ($line =~ /$pattern/);
 return 0 if (! $exit_on_fail);
 die "Line ($line) does not contain expected pattern ($pattern)";
}
 

sub get_link {
 return "    <link rel=\"stylesheet\" href=\"../../styles.css\">\n";
}

sub get_top_div {
 return "" .
"    <div class=\"sequoia-logo\"><a href=\"http://sequoiaproject.org\"><img src=\"http://sequoiaproject.org/wp-content/uploads/2017/08/sequoia-logo-rsna.jpg\" width=\"111\" height=\"53\"></a></div>
    <div class=\"rsna-logo\"><a href=\"http://sequoiaproject.org/rsna\"><img src=\"http://sequoiaproject.org/wp-content/uploads/2017/08/rsna-logo.png\" width=\"200\" height=\"25\"></a></div>
";
}

sub get_footer {
 return "
    <div class=\"footer\"><a></a>Copyright&copy; 2017-2018 The Sequoia Project. All rights reserved. <a href=\"http://sequoiaproject.org/privacy-policy/\">Privacy Policy</a></div>
";
}

sub write_one_test_document {
 my ($input_file, $output_file) = @_;

  my @lines = read_file($input_file);
  my $index = 1;
  open(my $fh, '>', $output_file) or die "Could not open for output: $output_file";
  foreach my $l(@lines) {
   switch ($index) {
    case 1 { print $fh $l; }
    case 2 { contains_pattern($l, "<html>", 1);  print $fh $l; }
    case 3 { contains_pattern($l, "<head>", 1);  print $fh $l; }
    case 4 { contains_pattern($l, "<meta", 1);   print $fh $l; }
    case 5 { contains_pattern($l, "charset", 1); print $fh $l; }
    case 6 { print $fh $l; print $fh get_link() if contains_pattern($l, "title>", 0); }
    case 7 { print $fh $l; print $fh get_link() if contains_pattern($l, "title>", 0); }
    case 8 { print $fh $l; print $fh get_top_div() if contains_pattern($l, "<body", 0); }
    case 9 { print $fh $l; print $fh get_top_div() if contains_pattern($l, "<body", 0); }
    else   { print $fh get_footer() if contains_pattern($l, "</body", 0);   print $fh $l; }
   }

   $index++;
  }
  close $fh;
}

sub extract_test_html {
 my $base = shift @_;
 my $actor= shift @_;

 my $template_file = "templates/$actor.html";
 my @template_lines = read_file($template_file);
 open (my $html, '>', "$actor.html");

 while (my $t = shift @template_lines) {
  last if contains_pattern($t, "REPLACE", 0);
  print $html $t;
 }

 print $html "  <ol>\n";

 foreach my $t(@_) {
  print "$base $actor $t\n";
  write_one_test_document("tests/$t/readme-$t.html", "testdoc/$actor/$t.html");
  write_html_item($html, $actor, $t);
 }

 print $html "  </ol>\n";
 while (my $t = shift @template_lines) {
  print $html $t;
 }
 close $html;
}

sub toolkit_header {
 return "
<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">
<html>
  <head>
    <meta http-equiv=\"content-type\" content=\"text/html;
      charset=windows-1252\">
    <title>Imaging Document Source: ids_2018-4800</title>
    <link rel=\"stylesheet\" href=\"../../styles.css\">
  </head>
  <body>
    <div class=\"sequoia-logo\"><a href=\"http://sequoiaproject.org\"><img src=\"http://sequoiaproject.org/wp-content/uploads/2017/08/sequoia-logo-rsna.jpg\" width=\"111\" height=\"53\"></a></div>
    <div class=\"rsna-logo\"><a href=\"http://sequoiaproject.org/rsna\"><img src=\"http://sequoiaproject.org/wp-content/uploads/2017/08/rsna-logo.png\" width=\"200\" height=\"25\"></a></div>
";
}

sub toolkit_trailer {
 return "
    <div class=\"footer\"><a></a>Copyright&copy; 2017-2018 The Sequoia Project. All rights reserved. <a href=\"http://sequoiaproject.org/privacy-policy/\">Privacy Policy</a></div>
  </body>
</html>
";
}


sub extract_test_html_toolkit {
 my $base = shift @_;
 my $actor= shift @_;

 my $template_file = "templates/$actor.html";
 my @template_lines = read_file($template_file);
 open (my $html, '>', "$actor.html");

 while (my $t = shift @template_lines) {
  last if contains_pattern($t, "REPLACE", 0);
  print $html $t;
 }

 print $html "  <ol>\n";

 foreach my $t(@_) {
  print "$base $actor $t\n";

  my $contents = get("$base/$t");
  $contents =~ s/[^[:ascii:]]+//g;
  open(my $fh, '>', "testdoc/$actor/$t.html");
  print $fh toolkit_header();
  print $fh $contents;
  print $fh toolkit_trailer();
  close $fh;
  write_html_item($html, $actor, $t);
 }
 print $html "  </ol>\n";
 while (my $t = shift @template_lines) {
  print $html $t;
 }
 close $html;
}

sub reg_tests {
 my @tests = (
	"11897",
	"11898",
	"11899",
	"11901",
	"11902",
	"11903",
	"11904",
	"11905",
	"11906",
	"11907",
	"11908",
	"11909",
	"11990",
	"11991",
	"11992",
	"11993",
	"11994",
	"11995",
	"11996",
	"11997",
	"11998",
	"11999",
	"12000",
	"12001",
	"12002",
	"12004",
	"12084",
	"12000",
	"12323",
	"12326",
	"12327",
	"12361",
	"12368",
	"12370",
	"12379",
	"15803",
	);
 return @tests;
}

sub rep_tests {
 my @tests = (
	"11966",
	"11979",
	"11983",
	"11986",
	"12021",
	"12029",
	"12369",
	"15816",
	);
}

sub idc_tests {
 my @tests = (
	"idc_2018-4830",
	"idc_2018-4831a",
	"idc_2018-4832a",
	"idc_2018-4832b",
	"idc_2018-4833a",
	"idc_2018-4833b",
	);
 return @tests;
}

sub ids_tests {
 my @tests = (
	"ids_2018-4800",
	"ids_2018-4801a",
	"ids_2018-4801b",
	"ids_2018-4801c",
	"ids_2018-4802a",
	"ids_2018-4802b",
	"ids_2018-4802c",
	"ids_2018-4803a",
	"ids_2018-4803b",
	"ids_2018-4803c",
	"ids_2018-4810",
	"ids_2018-4811",
	"ids_2018-4820",
	);
 return @tests;
}

sub iig_tests {
 my @tests = (
	"iig_2018-5400",
	"iig_2018-5401a",
	"iig_2018-5401b",
	"iig_2018-5401c",
	"iig_2018-5402a",
	"iig_2018-5402b",
	"iig_2018-5403a",
	"iig_2018-5404a",
	"iig_2018-5404b",
	"iig_2018-5404c",
	"iig_2018-5405a",
	"iig_2018-5405b",
	);
 return @tests;
}

sub rig_tests {
 my @tests = (
	"rig_2018-5420",
	"rig_2018-5421a",
	"rig_2018-5421b",
	"rig_2018-5421c",
	"rig_2018-5422a",
	"rig_2018-5422b",
	"rig_2018-5423a",
	"rig_2018-5424a",
	"rig_2018-5424b",
	"rig_2018-5424c",
	"rig_2018-5425a",
	"rig_2018-5425b",
	);
 return @tests;
}

sub get_tests {
 my ($actor) = @_;
 my @tests;

 switch ($actor) {
    case "idc" { @tests = idc_tests(); }
    case "ids" { @tests = ids_tests(); }
    case "iig" { @tests = iig_tests(); }
    case "rig" { @tests = rig_tests(); }
    case "reg" { @tests = reg_tests(); }
    case "rep" { @tests = rep_tests(); }
    else       { print "Unknown actor $actor\n"; }
 }
 return @tests;
}

sub process_actors {
 my $base = shift @_;
 foreach my $actor(@_) {
  my @tests = get_tests($actor);
  switch ($actor) {
    init_folder($actor);
    case /idc|ids|iig|rig/ { extract_test_html($base, $actor, @tests); }
    case /reg|rep/         { extract_test_html_toolkit($base, $actor, @tests); }
  }
 }
}

sub die_if_missing {
 foreach my $f(@_) {
  die "File/folder not found: <$f>" if (! -e $f);
 }
}

my $base = "http://localhost:9280/toolkit/testdoc";
my @tests;

die_if_missing("tests");

if (scalar(@ARGV) == 0) {
 process_actors($base, "idc", "ids", "iig", "rig", "reg", "rep");
} else {
 process_actors($base, @ARGV);
}

