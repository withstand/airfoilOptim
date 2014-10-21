#
# Copyright 2011 (c) Pointwise, Inc.
# All rights reserved.
#
# This sample script is not supported by Pointwise, Inc.
# It is provided freely for demonstration purposes only.
# SEE THE WARRANTY DISCLAIMER AT THE BOTTOM OF THIS FILE.
#

# ===============================================
# NACA 4-SERIES AIRFOIL GENERATOR AND
# BOUNDARY LAYER MESH GENERATOR
# ===============================================
# Written by Travis Carrigan
#
# v1: Jan 14, 2011
# v2: Sep 21, 2011
# v3: Oct 06, 2011
#

# Load Pointwise Glyph package and Tk
package require PWI_Glyph 2.17

proc parseArguments {ac av} {
    if {$ac >= 6} {
	set ::no_tk 1
    }

    if {$ac >= 1} {
	set ::naca [lindex $av 0]
    }

    if {$ac >=2 } {
	set ::initds [lindex $av 1]
    }

    if {$ac >=3 } {
	set ::cellgr [lindex $av 2]
    }
    if {$ac >=4 } {
	set ::bldist [lindex $av 3]
    }
    if {$ac >=5 } {
	set ::numpts [lindex $av 4]
    }
    if {$ac >=5 } {
	set ::outputfilename [lindex $av 5]
    }
}




proc tempfile {{filenameVar {}}} {
    set chars abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789
    if {$filenameVar ne {}} {
	upvar 1 $filenameVar filename
    }
    for {set i 0} {$i < 10} {incr i} {
	set filename /tmp/tcl_
	for {set j 0} {$j < 10} {incr j} {
	    append filename [string index $chars [expr {int(rand() * 62)}]]
	}
	if {![catch {open $filename {RDWR CREAT EXCL} 0600} channel]} {
	    return $channel
	}
    }
    error "failed to find an unused temporary file name"
}

proc writeOutput {fn} {

    # pw::Application setCAESolver {Stanford ADL/SU2} 3
    # pw::Application markUndoLevel {Select Solver}
    foreach nl [pw::Application getCAESolverNames] { if {[string first "SU2" $nl] != -1} { set su2solver $nl}}
    # puts $su2solver
    # Stanford ADL/SU2
    pw::Application setCAESolver $su2solver 2

    # pw::Application setCAESolver {Stanford ADL/SU2} 2
    # pw::Application markUndoLevel {Set Dimension 2D}

    set airfoilConList $::airfoilCon

    set farfieldConLen 0
    set farfieldCon 0
    foreach entity [pw::Grid getAll -type "pw::Connector"] {
	set conLength [$entity getTotalLength]
	if {$conLength > $farfieldConLen} {
	    set farfieldConLen $conLength
	    set farfieldCon $entity
	}
	#puts "[$entity getName] [$entity getTotalLength]"
    }

    set domain [pw::Grid getAll -type "pw::Domain"]

    set airfoilBC [pw::BoundaryCondition create]
    $airfoilBC setName "airfoil"

    foreach con $airfoilConList {
	$airfoilBC apply [list [list $domain $con]]
    }

    set farfieldBC [pw::BoundaryCondition create]
    $farfieldBC setName "farfield"

    $farfieldBC apply [list [list $domain $farfieldCon]]

    ###########################################
    #
    #foreach nl [pw::Application getCAESolverNames] { if {[string first "SU2" $nl] != -1} { set su2solver $nl}}
    # Stanford ADL/SU2

    set blkList [pw::Grid getAll -type "pw::Domain"]
    # ::pw::DomainStructured_1
    set export [pw::Application begin CaeExport $blkList]
    # ::pw::CaeExporter_1
    $export initialize -type CAE $fn
    # 1
    $export setAttribute FilePrecision Double
    $export verify
    # 1
    $export write
    # 1
    $export end

    puts "Finished write to $fn"
    puts "Save pw file in case of furthur use"
    pw::Application save "[tempfile].pw"
    ##############################################

}
# AIRFOIL GENERATION PROCEDURE
# -----------------------------------------------
#  leading edge radius (Rle), 
#  position of upper crest (Xup), upper crest point (Yup), upper crest curvature (Y XXup), 
#  position of lower crest (Xlo),lower crest point (Ylo),  lower crest curvature (Y XXlo),
#  trailing edge offset (Toff ), edge thickness (TTE) 
#  trailing edge direction angle (¦ÁTE ), trailing edge wedge angle (¦ÂTE), trailing
proc PARSEC{param} {
#	rle, xup, yup, kup, xlo, ylo, klo, yt, tt, at, bt
	set rle [lindex $param 0]
	
}


# AIRFOIL GENERATION PROCEDURE
# -----------------------------------------------
proc airfoilGen {} {

    # AIRFOIL INPUTS
    # -----------------------------------------------
    # m = maximum camber
    # p = maximum camber location
    # t = maximum thickness
    set m [expr {[string index $::naca 0]/100.0}]
    set p [expr {[string index $::naca 1]/10.0}]
    set a [string index $::naca 2]
    set b [string index $::naca 3]
    set c "$a$b"
    set t [expr {$c/100.0}]

    # GENERATE AIRFOIL COORDINATES
    # -----------------------------------------------
    # Initialize Arrays
    set x {}
    set xu {}
    set xl {}
    set yu {}
    set yl {}
    set yc {0}
    set yt {}

    # Airfoil step size
    set ds 0.001

    # Check if airfoil is symmetric or cambered
    if {$m == 0 && $p == 0 || $m == 0 || $p == 0} {set symm 1} else {set symm 0}

    # Get x coordinates
    for {set i 0} {$i < [expr {1+$ds}]} {set i [expr {$i+$ds}]} {lappend x $i}

    # Calculate mean camber line and thickness distribution
    foreach xx $x {

	# Mean camber line definition for symmetric geometry
	if {$symm == 1} {lappend yc 0}

	# Mean camber line definition for cambered geometry
	if {$symm == 0 && $xx <= $p} {
	    lappend yc [expr {($m/($p**2))*(2*$p*$xx-$xx**2)}]
	} elseif {$symm == 0 && $xx > $p} {
	    lappend yc [expr {($m/((1-$p)**2)*(1-2*$p+2*$p*$xx-$xx**2))}]
	}

	# Thickness distribution
	lappend yt [expr {($t/0.20)*(0.29690*sqrt($xx)-0.12600*$xx- \
					 0.35160*$xx**2+0.28430*$xx**3-0.10150*$xx**4)}]

	# Theta
	set dy [expr {[lindex $yc end] - [lindex $yc end-1]}]
	set th [expr {atan($dy/$ds)}]

	# Upper x and y coordinates
	lappend xu [expr {$xx-[lindex $yt end]*sin($th)}]
	lappend yu [expr {[lindex $yc end]+[lindex $yt end]*cos($th)}]

	# Lower x and y coordinates
	lappend xl [expr {$xx+[lindex $yt end]*sin($th)}]
	lappend yl [expr {[lindex $yc end]-[lindex $yt end]*cos($th)}]

    }

    # GENERATE AIRFOIL GEOMETRY
    # -----------------------------------------------
    # Create upper airfoil surface
    set airUpper [pw::Application begin Create]
    set airUpperPts [pw::SegmentSpline create]

    for {set i 0} {$i < [llength $x]} {incr i} {
	$airUpperPts addPoint [list [lindex $xu $i] [lindex $yu $i] 0]
    }

    set airUpperCurve [pw::Curve create]
    $airUpperCurve addSegment $airUpperPts
    $airUpper end

    # Create lower airfoil surface
    set airLower [pw::Application begin Create]
    set airLowerPts [pw::SegmentSpline create]

    for {set i 0} {$i < [llength $x]} {incr i} {
	$airLowerPts addPoint [list [lindex $xl $i] [lindex $yl $i] 0]
    }

    set airLowerCurve [pw::Curve create]
    $airLowerCurve addSegment $airLowerPts
    $airLower end

    # Create flat trailing edge
    set airTrail [pw::Application begin Create]
    set airTrailPts [pw::SegmentSpline create]
    $airTrailPts addPoint [list [lindex $xu end] [lindex $yu end] 0]
    $airTrailPts addPoint [list [lindex $xl end] [lindex $yl end] 0]
    set airTrailCurve [pw::Curve create]
    $airTrailCurve addSegment $airTrailPts
    $airTrail end

    # Zoom to airfoil
    pw::Display resetView

    puts "Airfoil construction completed."

}

# BOUNDARY LAYER MESH GENERATION PROCEDURE
# -----------------------------------------------
proc airfoilMesh {} {

    # BOUNDARY LAYER INPUTS
    # -----------------------------------------------
    # initDs = initial cell height
    # cellGr = cell growth rate
    # blDist = boundary layer distance
    # numPts = number of points around airfoil
    set initDs $::initds
    set cellGr $::cellgr
    set blDist $::bldist
    set numPts $::numpts

    # CONNECTOR CREATION, DIMENSIONING, AND SPACING
    # -----------------------------------------------
    # Get all database entities
    set dbEnts [pw::Database getAll]

    # Get the curve length of all db curves
    foreach db $dbEnts {
	lappend crvLength [$db getLength 1.0]
    }

    # Find trailing edge from minimum curve length
    if {[lindex $crvLength 0] < [lindex $crvLength 1]} {
	set min 0
    } else {
	set min 1
    }

    if {[lindex $crvLength $min] < [lindex $crvLength 2]} {
	set min $min
    } else {
	set min 2
    }

    set dbTe [lindex $dbEnts $min]

    # Get upper and lower surfaces
    foreach db $dbEnts {
	if {$db != $dbTe} {
	    lappend upperLower $db
	}
    }

    # Find y values at 50 percent length of upper and lower surfaces
    set y1 [lindex [[lindex $upperLower 0] getXYZ -arc 0.5] 1]
    set y2 [lindex [[lindex $upperLower 1] getXYZ -arc 0.5] 1]

    # Determine upper and lower surface db entities
    if {$y1 < $y2} {
	set dbLower [lindex $upperLower 0]
	set dbUpper [lindex $upperLower 1]
    } else {
	set dbLower [lindex $upperLower 1]
	set dbUpper [lindex $upperLower 0]
    }

    # Create connectors on database entities
    set upperSurfCon [pw::Connector createOnDatabase $dbUpper]
    set lowerSurfCon [pw::Connector createOnDatabase $dbLower]
    set trailSurfCon [pw::Connector createOnDatabase $dbTe]
    set cons "$upperSurfCon $lowerSurfCon $trailSurfCon"

    set ::airfoilCon $cons

    # Calculate main airfoil connector dimensions
    foreach con $cons {lappend conLen [$con getLength -arc 1]}
    set upperSurfConLen [lindex $conLen 0]
    set lowerSurfConLen [lindex $conLen 1]
    set trailSurfConLen [lindex $conLen 2]
    set conDim [expr int($numPts/2)]

    # Dimension upper and lower airfoil surface connectors
    $upperSurfCon setDimension $conDim
    $lowerSurfCon setDimension $conDim

    # Dimension trailing edge airfoil connector
    set teDim [expr int($trailSurfConLen/(10*$initDs))+2]
    $trailSurfCon setDimension $teDim

    # Set leading and trailing edge connector spacings
    set ltDs [expr 10*$initDs]

    set upperSurfConDis [$upperSurfCon getDistribution 1]
    set lowerSurfConDis [$lowerSurfCon getDistribution 1]
    set trailSurfConDis [$trailSurfCon getDistribution 1]

    $upperSurfConDis setBeginSpacing $ltDs
    $upperSurfConDis setEndSpacing $ltDs
    $lowerSurfConDis setBeginSpacing $ltDs
    $lowerSurfConDis setEndSpacing $ltDs

    # Create edges for structured boundary layer extrusion
    set afEdge [pw::Edge createFromConnectors -single $cons]
    set afDom [pw::DomainStructured create]
    $afDom addEdge $afEdge

    # Extrude boundary layer using normal hyperbolic extrusion method
    set afExtrude [pw::Application begin ExtrusionSolver $afDom]
    $afDom setExtrusionSolverAttribute NormalInitialStepSize $initDs
    $afDom setExtrusionSolverAttribute SpacingGrowthFactor $cellGr
    $afDom setExtrusionSolverAttribute NormalMarchingVector {0 0 -1}
    $afDom setExtrusionSolverAttribute NormalKinseyBarthSmoothing 3
    $afDom setExtrusionSolverAttribute NormalVolumeSmoothing 0.3
    $afDom setExtrusionSolverAttribute StopAtHeight $blDist
    $afExtrude run 1000
    $afExtrude end

    # Reset view
    pw::Display resetView
    puts "Meshing completed."

}

# PROCEDURE TO DELETE ANY EXISTING GRID ENTITIES
# -----------------------------------------------
proc cleanGrid {} {

    set grids [pw::Grid getAll -type pw::Connector]

    if {[llength $grids]>0} {
	foreach grid $grids {$grid delete -force}
    }

}

# PROCEDURE TO DELETE ANY EXISTING GEOMETRY
# -----------------------------------------------
proc cleanGeom {} {

    cleanGrid

    set dbs [pw::Database getAll]

    if {[llength $dbs]>0} {
	foreach db $dbs {$db delete -force}
    }

}

###########################################################################
# main program
###########################################################################

# Default NACA airfoil
set naca 0012
# Default boundary layer parameters
set initds 0.0001
set cellgr 1.1
set bldist 0.5
set numpts 100
set outputfilename "tmp.su2"
# airfoil con list
set airfoilCon {}

set no_tk 0

parseArguments $argc $argv

if {$no_tk == 1} {
    cleanGeom
    airfoilGen
    cleanGrid
    airfoilMesh
    writeOutput $outputfilename
} else {

    pw::Script loadTk

    # AIRFOIL GUI CREATION
    # -----------------------------------------------
    wm title . "Airfoil Mesh Generator"

    set labelWidth 20
    set entryWidth 10
    set buttonWidth 10

    # Create geometry information frame
    grid [ttk::frame .geom -padding "5 5 5 5"] -column 0 -row 0 -sticky nwes

    set imported 0
    set fname "Browse for airfoil data file..."

    grid [labelframe .geom.lf -text "1. Generate or Import Geometry" -font {-slant italic} -padx 5 -pady 5]
    grid [ttk::label .geom.lf.nacal -text "NACA 4-Series Airfoil" -width $labelWidth] -column 0 -row 0 -sticky w
    grid [ttk::entry .geom.lf.nacae -width $entryWidth -textvariable naca] -column 1 -row 0 -sticky e
    grid [ttk::button .geom.lf.gob -text "Create" -width $buttonWidth -command {
    if {$imported} {
	set fname "Browse for airfoil data file..."
	.geom.lf.browse configure -text fname
    }
    cleanGeom
    airfoilGen
}] -column 2 -row 0 -sticky e
    grid [ttk::button .geom.lf.geomb -text "Browse" -width $buttonWidth -command {
    set types {
	{{Segment Files} {.dat} }
	{{IGES Files}    {.igs} }
	{{IGES Files}    {.iges}}
	{{DBA Files}     {.dba} }
	{{All Files}     *      }
    }
    set fname [tk_getOpenFile -title "Select Airfoil Segment File" -filetypes $types]
    if {[file readable $fname]} {
	set entryWidthBrowse [expr $labelWidth+$entryWidth+1]
	set fileLength [string length $fname]
	set xv [expr $fileLength-$entryWidthBrowse]
	if {$xv<0} {set xv 0}
	.geom.lf.browse xview $xv
	cleanGeom
	pw::Database import $fname
	set imported 1
    } else {
	puts "Can't read segment file."
	set fname "Browse for airfoil data file..."
	.geom.lf.browse configure -text fname
	set imported 0
    }
}] -column 2 -row 1 -sticky e
    grid configure [entry .geom.lf.browse -width [expr $labelWidth+$entryWidth+1] -text fname] -columnspan 2 -row 1 -sticky e

    # Create mesh information frame
    grid [ttk::frame .mesh -padding "5 5 5 5"] -column 0 -row 1 -sticky nwes

    grid [labelframe .mesh.lf2 -text "2. Define Boundary Layer Parameters" -font {-slant italic} -padx 5 -pady 5]
    grid [ttk::label .mesh.lf2.initdsl -text "Initial Cell Height" -width $labelWidth] -column 0 -row 0 -sticky w
    grid [ttk::entry .mesh.lf2.initdse -width $entryWidth -textvariable initds] -column 1 -row 0 -sticky e
    grid [ttk::label .mesh.lf2.cellgrl -text "Cell Growth Rate" -width $labelWidth] -column 0 -row 1 -sticky w
    grid [ttk::entry .mesh.lf2.cellgre -width $entryWidth -textvariable cellgr] -column 1 -row 1 -sticky e
    grid [ttk::label .mesh.lf2.numlayerl -text "Boundary Layer Height" -width $labelWidth] -column 0 -row 2 -sticky w
    grid [ttk::entry .mesh.lf2.numlayere -width $entryWidth -textvariable bldist] -column 1 -row 2 -sticky e
    grid [ttk::label .mesh.lf2.cellarl -text "Points Around Airfoil" -width $labelWidth] -column 0 -row 3 -sticky w
    grid [ttk::entry .mesh.lf2.cellare -width $entryWidth -textvariable numpts] -column 1 -row 3 -sticky e
    grid [ttk::button .mesh.lf2.gob -text "Mesh" -width $buttonWidth -command {cleanGrid; airfoilMesh}] -column 2 -row 3 -sticky e

    # Close GUI
    grid [ttk::frame .close -padding "5 0 5 5"] -column 0 -row 2 -sticky nwes
    grid anchor .close e
    grid [ttk::label .close.output -text "File name" -width $labelWidth] -column 0 -row 0 -sticky w
    grid [ttk::entry .close.filename -width $entryWidth -textvariable outputfilename] -column 1 -row 0 -sticky w
    grid [ttk::button .close.gob -text "WriteToFile" -width $buttonWidth -command {writeOutput $outputfilename}] -column 2 -row 0 -sticky e

    foreach w [winfo children .geom] {grid configure $w -padx 5 -pady 5}
    foreach w [winfo children .geom.lf] {grid configure $w -padx 5 -pady 5}
    foreach w [winfo children .mesh] {grid configure $w -padx 5 -pady 5}
    foreach w [winfo children .mesh.lf2] {grid configure $w -padx 5 -pady 5}
    foreach w [winfo children .close] {grid configure $w -padx 17 -pady 0}
    focus .geom.lf.nacae

    ::tk::PlaceWindow . widget
}

# END SCRIPT

#
# DISCLAIMER:
# TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, POINTWISE DISCLAIMS
# ALL WARRANTIES, EITHER EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED
# TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE, WITH REGARD TO THIS SCRIPT.  TO THE MAXIMUM EXTENT PERMITTED
# BY APPLICABLE LAW, IN NO EVENT SHALL POINTWISE BE LIABLE TO ANY PARTY
# FOR ANY SPECIAL, INCIDENTAL, INDIRECT, OR CONSEQUENTIAL DAMAGES
# WHATSOEVER (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF
# BUSINESS INFORMATION, OR ANY OTHER PECUNIARY LOSS) ARISING OUT OF THE
# USE OF OR INABILITY TO USE THIS SCRIPT EVEN IF POINTWISE HAS BEEN
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGES AND REGARDLESS OF THE
# FAULT OR NEGLIGENCE OF POINTWISE.
#
