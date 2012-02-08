#!/usr/bin/perl

####################################################################################################

use strict;
use warnings;

####################################################################################################

use File::Copy;
use File::Find;
use File::Path qw(mkpath);
use File::Basename;

####################################################################################################

my $file_count = 0;
my $java_file_count = 0;

my $DG_ROOT= $ARGV[0];
my $DB_ROOT= $ARGV[1];
my $DEST_DIR = $ARGV[2];
my @SRC_DIR = ($DG_ROOT . "/LDJ_Commun/Commun",
	       $DG_ROOT . "/LDJ_Commun/Ouvea",
	       $DG_ROOT . "/LDJ_Commun/Ressources",
	       $DG_ROOT . "/LDJ_Connecteurs_P",
	       $DG_ROOT . "/LDJ_Logique_P/Adaptateur",
	       $DG_ROOT . "/LDJ_Logique_P/AdaptateurXicCoherence",
	       $DG_ROOT . "/LDJ_Logique_P/AlimRejets",
	       $DG_ROOT . "/LDJ_Logique_P/Asynchrone",
	       $DG_ROOT . "/LDJ_Logique_P/ClientEJBAdminRejet",
	       $DG_ROOT . "/LDJ_Logique_P/ClientJava",
	       $DG_ROOT . "/LDJ_Logique_P/ClientLD",
	       $DG_ROOT . "/LDJ_Logique_P/CobolJavaSynchrone",
	       $DG_ROOT . "/LDJ_Logique_P/CompteRenduEvt",
	       $DG_ROOT . "/LDJ_Logique_P/CompteRenduEvtApi",
	       $DG_ROOT . "/LDJ_Logique_P/Contextes",
	       $DG_ROOT . "/LDJ_Logique_P/Habillage",
	       $DG_ROOT . "/LDJ_Logique_P/LogiqueArchiImpl",
	       $DG_ROOT . "/LDJ_Logique_P/MockLogiqueArchi",
	       $DG_ROOT . "/LDJ_Logique_P/NCPUtilitaires",
	       $DG_ROOT . "/LDJ_Logique_P/Persistance",
	       $DG_ROOT . "/LDJ_Logique_P/PersistanceRessources",
	       $DG_ROOT . "/LDJ_Logique_P/Rejets",
	       $DB_ROOT . "/LDJ_Connecteurs_B/BatchAdministrationIHM",
	       $DB_ROOT . "/LDJ_Connecteurs_B/BatchAdministrationOudini",
	       $DB_ROOT . "/LDJ_Connecteurs_B/BatchClient",
	       $DB_ROOT . "/LDJ_Connecteurs_B/DT4",
	       $DB_ROOT . "/LDJ_Connecteurs_B/DT4Habillage",
	       $DB_ROOT . "/LDJ_Connecteurs_B/Orchestration",
	       $DB_ROOT . "/LDJ_Logique_B/BatchCommun",
	       $DB_ROOT . "/LDJ_Connecteurs_B/BatchAdministration",
	       $DB_ROOT . "/LDJ_Connecteurs_B/Orchestration",
	       $DB_ROOT . "/LDJ_Logique_B/BatchHistorisation",
	       $DB_ROOT . "/LDJ_Logique_B/BatchLivraisonAvecSand",
	       $DB_ROOT . "/LDJ_Logique_B/BatchPurge",
	       $DB_ROOT . "/LDJ_Logique_B/startup",
	       $DB_ROOT . "/LDJ_Logique_B/BatchLivraison",
	       $DB_ROOT . "/LDJ_Logique_B/BatchNG",
	       $DB_ROOT . "/LDJ_Logique_B/BatchService",
	       $DB_ROOT . "/LDJ_Tests_B/DeleteTableBatchIHM",
	       $DB_ROOT . "/LDJ_Tests_B/GenerateurDDL",
	       $DB_ROOT . "/LDJ_Tests_B/TestsConfiguration");

####################################################################################################

sub extract_package_from_java_source {
    my ($file_name) = @_;

    open my $handler, "<$file_name" or die "Failed to open file $file_name : $!" ;

    while ( my $line = <$handler> ) {
	if ( $line =~ /^\s*package\s+(.+)\s*;/ ) { # extract package name from  a line with package directive
	    return $1;
	}
    }

    # Oups, no line matched our regexp, we failed to find a package name in this source code

    die "Failed to extract package from file : $file_name" ;
}

sub process_file {
    my $file_fullpath = $File::Find::name;

    $file_count++;

    if ( $file_count%1000 == 0) {
	print "-- File count : " , $file_count , "\n";
    }

    # We're only interested in .java files
    return unless $file_fullpath =~ /\.java$/ ;

    # Split fullpath in its components
    my ($file_name,$file_path,$file_suffix) = fileparse($file_fullpath);

    # Extract package name from java source file
    my $package_name = extract_package_from_java_source($file_fullpath);

    # Compute file offset from package name
    (my $package_offset = $package_name ) =~ s/\./\//g ;
    
    # Compute destination file full path

    my $dest_dir = $DEST_DIR . "/" . $package_offset ;
    my $dest_fullpath = $dest_dir . "/" . $file_name ;

    # Create destination directory
    mkpath($dest_dir);

    # Copy file
    copy($file_fullpath,$dest_fullpath) or die "Failed to copy file $dest_fullpath : $!";

    $java_file_count++;

    if ( $java_file_count%1000 == 0) {
	print "----- Java File count : " , $java_file_count , "\n";
    }

}

####################################################################################################

# Main 

# Create destination directory
mkdir $DEST_DIR;

# Run "process_file" for each file in @SRC_DIR (recursively)
find(\&process_file, @SRC_DIR);

print "Nb total de fichiers : $file_count \n";
print "Nb total de fichiers java copiés : $java_file_count \n";

####################################################################################################
