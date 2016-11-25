#!/usr/bin/perl
use strict;
use warnings;

my $current_year = 0;
for my $file (reverse `git ls-files`) {
    chomp $file;
    if ($file =~ s/^"(.+)"/$1/) {
        $file =~ s/\\(\d\d\d)/chr oct $1/ge;
    }

    next unless $file =~ /^(20\d\d)/; # ignore viewer/, .gitignore, etc
    my $year = $1;

    next if $file =~ /\bedithk\b/
         || $file =~ /^200/; # only care about games from 2016 on

    if ($current_year != $year) {
        if ($current_year) {
            print qq{</ul>\n};
        }
        $current_year = $year;
        print qq{<h1>$current_year</h1>\n<ul>\n};
    }


    my $label;
    # 2016/04-23--04-28-B.K..sgf
    if (my @matches = $file =~ m{^(20\d\d)/(\d\d)-(\d\d)--(\d\d)-(\d\d)-(.*?)\.sgf$}) {
        my ($year, $start_month, $start_day, $end_month, $end_day, $opponent) = @matches;
        s/^0// for $start_month, $start_day, $end_month, $end_day;
        $label = "$start_month/$start_day-$end_month/$end_day: $opponent";
    }
    # 2016/04-22-Magnetic-Spark.sgf
    # 2016/07-10a-Mark-Nahabedian.sgf
    elsif (@matches = $file =~ m{^(20\d\d)/(\d\d)-(\d\d)(\w?)-(.*?)\.sgf$}) {
        my ($year, $month, $day, $order, $opponent) = @matches;
        s/^0// for $month, $day;
        $label = "$month/$day: $opponent";
    }
    else {
        warn "Unable to parse filename $file\n";
    }

    print qq{<li><a href="index.html?sgf=../$file">$label</a></li>\n};
}

print qq{</ul>\n};
