#
# Cookbook Name:: e2webexperimental
# Recipe:: default
#
# Copyright 2013, Everything2 Media LLC
#
# All rights reserved - Do Not Redistribute
#

package 'libmason-perl' #Mason2
package 'libexception-class-perl' #Bug in ubuntu's package, actually requires this
package 'libmoose-perl' #modern Perl object system framework
package 'libnamespace-autoclean-perl' #Perl module to remove all imported symbols at the end of the compile cycle
