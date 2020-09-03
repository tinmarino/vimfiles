# define exports from this module
package Tool;
our @EXPORT = qw( shout );

use base 'ToolSet';
 

ToolSet->use_pragma( 'strict' );
ToolSet->use_pragma( 'warnings' );
#ToolSet->use_pragma( 'v5.26' );
ToolSet->use_pragma( qw/feature say switch/ ); # perl 5.10
 
# define exports from other modules
ToolSet->export(
    'File::Slurp'  => 'read_file',
    # 'Carp'          => undef,       # get the defaults
    # 'Scalar::Util'  => 'refaddr',   # or a specific list
);
 
sub shout { print uc shift };
 
1; # modules must return true
