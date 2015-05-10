use strict;
use warnings;
use Data::Dumper;
use DDP;

open(my $in,"<","input.xml");
my @str2=<$in>;
my $str;
for (@str2){
   $str.=$_;
}

my $out=[];
my @stack;
my $q1;
my $q2;
my $text;
$str=~/\G<(.*?>)/gcs;
func($1,1); # 1 means that it's the first tag

while(1){
   $q1=$str=~/\G(.*?)</gcs;
   $text=$1;
   func2($text) if $q1 && $text=~/./;
   $q2=$str=~/\G(.*?>)/gcs;
   func($1) if $q2;
   last if (!$q1 || !$q2);

}

print Dumper($out);
p $out;

sub func{
   $_=shift;
   return if /^!--(?:.*)--$/;
   my $new=1;
   if (/\/\s*$/ || $_[1]){ #if the tag is the first we don't push it in our stack of tags
      $new=0;
   }
   my $ref=$out;
   for my $tmp (@stack){
      $ref=$ref->[$tmp];
   }
   /\s*(\/?)\s*(.*?)[\s>]/gc;

   if($1 eq '/'){
      if($2 ne $ref->[0]){
         die "mistake $2, $ref->[0]";
      }
      pop @stack;
   }

   else{
      if($new){
         push @stack,$#$ref+1;
      }
      if($_[1]){
         push @$ref,$2;
         push @$ref,[];
      }
      else{
         push @$ref,[$2,[]];
         $ref=$ref->[$#$ref];
      }
      while(/\G\s*(.*?)="(.*?)"/gc){
         push @{$ref->[1]},[$1,$2];
      }
   }
}

sub func2{
   my $ref=$out;
   for my $tmp (@stack){
      $ref=$ref->[$tmp];
   }
   push @$ref,$_[0];
}
