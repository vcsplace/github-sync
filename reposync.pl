#!/usr/bin/env perl
use strict;
my @git_bare=qw/git --bare --git-dir/;
sub run {
	print STDERR join(" ",@_),"\n";
	return system(@_) == 0;
}

if(!@ARGV) {
	while(<STDIN>) {
		chomp;
		push @ARGV,$_;
	}
}
foreach my $url (@ARGV) {
	my $project;
	my $repo;
	if($url =~ m/\/([^\/]+)\/([^\/]+)$/) {
		$project = $1;
		$repo = "$1/$2";
	}
	elsif($url =~ m/\/([^\/]+)$/) {
		$repo = $1;
	}
	else {
		next;
	}
	print STDERR "$url -> $repo ...";
	if(! -d $project) {
		print STDERR "\ncreating directory $project ...";
		if(!mkdir $project) {
			print STDERR "\tfailed\n";
			next;
		}
	}
	if(! -d $repo) {
		print STDERR "\ninitial cloning ...\n";
		if(!run(qw/git clone --bare/,$url,$repo)) {
			print STDERR "\tfailed\n";
			next;
		}
	}
	print STDERR "\nsyncing $repo ...\n";
	run(@git_bare,$repo,qw/remote rm origin/);
	run(@git_bare,$repo,qw/remote add origin/,$url);
	run(@git_bare,$repo,qw/fetch -v/);
	run(@git_bare,$repo,qw/reset --soft/,"refs/remotes/origin/master");
	run(@git_bare,$repo,qw/remote -v/);
	run(@git_bare,$repo,qw/branch -av/);
#	if(!run(qw/git --bare --git-dir/,$repo,qw/fetch -v/,$url)) {
#		print STDERR "\tfailed\n";
#		next;
#	}
}

