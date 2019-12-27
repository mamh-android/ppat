use Getopt::Long;
use Data::Dumper;
Getopt::Long::GetOptions(
 'cfg_list:s'=>\$cfg_list,
 'type:s'=>\$type,
  );

#voltage;core;ddr;gc;gc_sclk;gc2d;vpu

  my  @config_list=(
'.;624000;528000;416000;416000;0;416000;',
'.;1248000;800000;624000;624000;312000;528750;',
'.;1526000;800000;705000;705000;416000;528750;',
'.;1803000;800000;705000;705000;416000;528750;');
  $cfg_list=~s/\s//g;  
sub Judge_By_Name()
{ 
  my $line=0;
  foreach my  $config_name(@config_list)
  { 
   $line++;
   #print "$config_name\n";
   if ($config_name eq $cfg_list )
   {
    if ($cfg_list=~ /\;0\;/  || $cfg_list=~ /^0\;/ )
     {return $line;}
    else
     {return $line;}
   }
  }
   return 0 ;
  
}

sub Judge_By_Name_ignore()
{ 
#print $cfg_list;
  my $line=0;
  foreach my  $config_name(@config_list)
  { 
   $line++;
   if ($cfg_list=~/$config_name/s)
   { 
    #print "$config_name\n";
    if ($cfg_list=~ /\;0\;/  || $cfg_list=~ /^0\;/ )
     {return $line;}
    else
     {return $line;}
   }
  }
   return 0 ;
}

if ($type eq 0)
{ 
 #print &Judge_By_Name;
 exit(&Judge_By_Name);
}

if ($type eq 1)
{ 
  #print &Judge_By_Name_ignore;
  exit(&Judge_By_Name_ignore);
}
