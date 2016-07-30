// Title: TUNEL CELL COUNTER 
// Revision version: 2.0 - 07/24/2016
// First version: 1.0 - 02/15/2015 

// Description: This macro performs retinal layer segmentation and fluorescent-labeled cell quantitation
// from retinal cryosections. 
//------------------------------------
// Authors: Daniel E. Maidana, M.D. and Demetrios G. Vavvas, M.D., Ph.D.
// Massachusetts Eye and Ear Infirmary
// Harvard Medical School
// 243 Charles Street, Boston MA (02114)
// Unites States of America
// Website: http://imagej.net/RETINA_Analysis_Toolkit
//------------------------------------
// Note: Please review istructions before use!
//---------------------------------------------------------------------------------
//	DIALOG
	var New = 0;
	var Spatial_Scale = 0
	var Minimum_Cell_Size = 0;
	var Maximum_Cell_Size = 0;
	var Cell_Roundness = 0;
	var Count_Fragments = 0;
	var Threshold_Sensitivity = 0;
	var Area_To_Measure = 0;
	var Green_Cells = 0;
	var Red_Cells = 0;
	var Circularity_Min = 0;
	var Circularity_Max = 0;
	
//	SETUP
	var dir = 0;
	var name = 0; 
	var path = 0; 
	var path2 = 0;
	var w = 0;
	var h = 0;
	var Stack_ID = 0;
	var Manual_Freehand_ID = 0;
	var Merged_ID = 0;
	var Green_ID = 0; 
	var Red_ID = 0; 
	var Blue_ID = 0; 
	var ONL_Total_Cells_ID = 0;	
	var INL_Total_Cells_ID = 0;
	var Layer_Thresholding_ID = 0;	
	var ONL_Segmentation_ID = 0;
	var INL_Segmentation_ID = 0;

//	ONL LAYER	
	var Layer_Thresholding_ID = 0;
	var Thresholded_Layers_ID = 0;
	var ONL_Thresholded_ID = 0;
	var ONL_Area_Value = 0;
	var ONL_Area_ID = 0;
	var ONL_for_INL_ID = 0;

//	INL LAYER
	var ONL_Dilated_ID = 0;
	var ONL_Dilated_Crop_ID = 0;
	var Result_INL_Segmentation_ID_ONL_Dilated_ID = 0;
	var INL_Thresholded_ID = 0;
	var INL_Area_Value = 0;
	var INL_Area_ID = 0;

// 	MANUAL AREA
	var Manual_Area_Value = 0;

//	CELL COUNTS
	var Red_ID = 0;
	var ONL_Red_Count = 0;
	var INL_Red_Count = 0;
	var Green_ID = 0;
	var ONL_Green_Count = 0;
	var INL_Green_Count = 0;
	var Manual_Red_Count = 0;
	var Manual_Green_Count = 0;

	var ONL_Rank_Max = 0;
	var INL_Rank_Max = 0;

//---------------------------------------------------------------------------------
//MACRO

//DIALOG

w = getWidth; 	
h = getHeight; 
Width_S = ""+w;
Height_S = ""+h;
Image_Res = Width_S + " x " + Height_S + " pixels";

Downscaling_Factor_1 = w/1344;
Downscaling_Factor_2 = w/1200;

Downscaled_Width_1 = w/Downscaling_Factor_1;
Downscaled_Height_1 = h/Downscaling_Factor_1;
Downscaled_Width_1_S = ""+Downscaled_Width_1;
Downscaled_Height_1_S = ""+Downscaled_Height_1;
Downscaling_Res_1 = Downscaled_Width_1_S + " x " + Downscaled_Height_1_S + " pixels";

Downscaled_Width_2 = w/Downscaling_Factor_2;
Downscaled_Height_2 = h/Downscaling_Factor_2;
Downscaled_Width_2_S = ""+Downscaled_Width_2;
Downscaled_Height_2_S = ""+Downscaled_Height_2;
Downscaling_Res_2 = Downscaled_Width_2_S + " x " + Downscaled_Height_2_S + " pixels";

Html = "<html>"
     +"Visit us at: <h1>http://imagej.net/RETINA_Analysis_Toolkit</h1>"
		
Dialog.create("TUNEL Cell Counter");
Dialog.addChoice("Microscope Magnification", newArray("20x", ""));
Dialog.addChoice("Image Native Resolution", newArray(Image_Res, ""));
Dialog.addNumber("        Image Native Spatial Scale (pixels/microns):", 3.096);
Dialog.addChoice("Image Rescaling Options", newArray(Downscaling_Res_1, Downscaling_Res_2));
Dialog.addSlider("Minimum Cell Area (microns2):", 0, 50, 5);
Dialog.addSlider("Maximum Cell Area (microns2):", 1, 100, 100);
Dialog.addChoice("Cell Roundness", newArray("Count All", "Count Mostly Rounded", "Count Mostly Not Rounded"));
Dialog.addChoice("Retina Area Selection", newArray("Automated ONL & INL", "Manual Freehand Selection"));
Dialog.addChoice("Threshold Sensitivity", newArray("Standard", "High (more cells)"));
Dialog.addCheckbox("Green Cells (FITC, GFP, AF488, etc)", true);
Dialog.addCheckbox("Red Cells (Texas Red, Cy5, AF594, AF647, etc)", true);
Dialog.addHelp(Html);
Dialog.show();

//File.openDialog("Choose the file to Open:"); 
Mic_Res = Dialog.getChoice();
Native_Res = Dialog.getChoice();
Native_Spatial_Scale = Dialog.getNumber();
Downscaled_Res = Dialog.getChoice()
Minimum_Cell_Size_Microns = Dialog.getNumber();
Maximum_Cell_Size_Microns = Dialog.getNumber();
Cell_Roundness = Dialog.getChoice();
Area_To_Measure_I = Dialog.getChoice();
Threshold_Sensitivity = Dialog.getChoice();
Green_Cells = Dialog.getCheckbox();
Red_Cells = Dialog.getCheckbox();

if (Downscaled_Res == Downscaling_Res_1) {
	Downscaling_Factor = Downscaling_Factor_1;
} else {	
	Downscaling_Factor = Downscaling_Factor_2;
}

Downscaled_Spatial_Scale = Native_Spatial_Scale/Downscaling_Factor;

Minimum_Cell_Size_Pixels = (sqrt(Minimum_Cell_Size_Microns)*Downscaled_Spatial_Scale)*(sqrt(Minimum_Cell_Size_Microns)*Downscaled_Spatial_Scale);
Maximum_Cell_Size_Pixels = (sqrt(Maximum_Cell_Size_Microns)*Downscaled_Spatial_Scale)*(sqrt(Maximum_Cell_Size_Microns)*Downscaled_Spatial_Scale);


/////////---------------

if (Cell_Roundness == "Count All") {
	Circularity_Min = 0.00;
	Circularity_Max = 1.00;
} else if (Cell_Roundness == "Count Mostly Rounded") {
	Circularity_Min = 0.50;
	Circularity_Max = 1.00;
} else if (Cell_Roundness == "Count Mostly Not Rounded") {
	Circularity_Min = 0.00;
	Circularity_Max = 0.50;
}

if (Area_To_Measure_I == "Automated ONL & INL") {
	Area_To_Measure = 1;
} else {
	Area_To_Measure = 0;
}
	
setBatchMode(true);

macro "RETINA Cell Counter" {
if ((Area_To_Measure == 1) && (Green_Cells == 1) && (Red_Cells == 1)) {  // AUTOMATED BOTH GREEN AND RED CELLS 
	Setup();
	ONL_Area();
	INL_Area();
	ONL_INL_Red_Function();
	ONL_INL_Green_Function();
	Results_Array();
} else if ((Area_To_Measure == 1) && (Green_Cells == 1) && (Red_Cells == 0)) {   // AUTOMATED ONLY GREEN CELLS 
	Setup();
	ONL_Area();
	INL_Area();
	ONL_INL_Green_Function();
	Results_Array();
} else if ((Area_To_Measure == 1) && (Green_Cells == 0) && (Red_Cells == 1)) {  // AUTOMATED ONLY RED CELLS 
	Setup();
	ONL_Area();
	INL_Area();
	ONL_INL_Red_Function();
	Results_Array();
} else if ((Area_To_Measure == 0) && (Green_Cells == 1) && (Red_Cells == 1)) {   // MANUAL AND BOTH GREEN AND RED CELLS 
	Setup();
	Manual_Selection();
	Manual_Red_Function();
	Manual_Green_Function();
	Results_Array();
} else if ((Area_To_Measure == 0) && (Green_Cells == 1) && (Red_Cells == 0)) {   // MANUAL ONLY GREEN CELLS 
	Setup();
	Manual_Selection();
	Manual_Green_Function();
	Results_Array();
} else if ((Area_To_Measure == 0) && (Green_Cells == 0) && (Red_Cells == 1)) {  //  MANUAL ONLY RED CELLS 
	Setup();
	Manual_Selection();
	Manual_Red_Function();
	Results_Array();
}
}
setBatchMode(false);

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//FUNCTIONS

function Setup() {
	New = getImageID();
	dir = getDirectory("image");
	name = getTitle; 
	path = dir+name;
	path2 = path+" Files";
	File.makeDirectory(path2);
	run("ROI Manager...");
	run("Labels...", "color=white font=14 show use draw bold");
	New_W = w/Downscaling_Factor;
	New_H = h/Downscaling_Factor;
	Downscaling_Factor_Ratio = 1/Downscaling_Factor;
	run("Scale...", "x=&Downscaling_Factor_Ratio y=&Downscaling_Factor_Ratio width=&New_W height=&New_W interpolation=Bilinear average create");
	Downscaled_Image_ID = getImageID();
	selectImage(Downscaled_Image_ID);
	saveAs("jpeg", path2+"/Downscaled Original Image.jpg");
	w = getWidth; 	
	h = getHeight; 
  	run("Profile Plot Options...", "width=450 height=200 font=12 minimum=0 maximum=0 draw draw_ticks interpolate sub-pixel");
	run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
	run("Duplicate...", "title=STACK");
	Stack_ID = getImageID();
	run("Duplicate...", "title=FREEHAND");
	Manual_Freehand_ID = getImageID();
	run("Duplicate...", "title=MERGED");
	Merged_ID = getImageID(); 
	selectImage(Stack_ID);
	run("RGB Stack");
	run("Stack to Images");
	selectImage("Green");
	Green_ID = getImageID(); 
	selectImage("Red");
	Red_ID = getImageID(); 
	selectImage("Blue");
	Blue_ID = getImageID(); 
	run("Duplicate...", "title=[ONL_Total_Cells_ID]"); 
	ONL_Total_Cells_ID = getImageID(); 
	run("Duplicate...", "title=[INL_Total_Cells_ID]");
	INL_Total_Cells_ID = getImageID(); 	
	run("Duplicate...", "title=[ONL_Segmentation_ID]");
	ONL_Segmentation_ID = getImageID(); 	
	///saveAs("jpeg", path2+"/1.ONL_Segmentation_ID.jpg");
	run("Duplicate...", "title=[INL_Segmentation_ID]");
	INL_Segmentation_ID = getImageID(); 
	//saveAs("jpeg", path2+"/2.INL_Segmentation_ID.jpg");
	selectImage(Blue_ID);
	//run("Enhance Contrast...", "saturated=10");
	run("Gaussian Blur...", "sigma=6");
	run("Duplicate...", "title=[Layer_Thresholding_ID]");
	Layer_Thresholding_ID = getImageID(); 	
	//saveAs("jpeg", path2+"/3.Layer_Thresholding_ID.jpg");
	//run("Duplicate...", "title=[INL_Segmentation_ID]");
	//INL_Segmentation_ID = getImageID(); 	
}

function ONL_Area() {
	run("ROI Manager...");
	roiManager("Reset");
	selectImage(Layer_Thresholding_ID);
	run("Enhance Contrast...", "saturated=10");
	setAutoThreshold("Moments dark");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Make Binary");
	for (i = 0; i < 3; i++) {
	run("Erode");
	}
	run("Remove Outliers...", "radius=14 threshold=50 which=Dark");
	run("Fill Holes");
	run("Set Measurements...", "area display redirect=None decimal=9");
	run("Analyze Particles...", "size=100000-Infinity pixel clear add");
	roiManager("Show All without labels");
	Thresholded_Layers_ID = getImageID();
	//saveAs("jpeg", path2+"/Thresholded_Layers_ID.jpg");
	selectImage(Thresholded_Layers_ID);
	ONL_Array = newArray();
	count = roiManager("count");
	for (i=0 ; i<count; i++) {
    	roiManager("Select", i);
    	roiManager("Measure");
    	ONL_Thresholded_Areas = getResult("Area",0);
    	roiManager("Rename", ONL_Thresholded_Areas);
    	ONL_Array_Concat = Array.concat(ONL_Array,ONL_Thresholded_Areas);
    	ONL_Array = ONL_Array_Concat;    
    	run("Clear Results");
	}
	Array.getStatistics(ONL_Array_Concat, min, max, mean, std);
	ONL_Area_Larger = max;
	run("Clear Results");
	for (i=0; i<count; i++) {
	 roiManager("Select", i);
	 roiManager("Measure");
	 Area_Sorting = getResult("Area",0);
	 if (Area_Sorting == ONL_Area_Larger) {
	 	ONL_Rank_Max = i;
	 	run("Clear Results");
	 } else {
	 }	   
	run("Clear Results");
	}
	newImage("ONL_Area", "8-bit white", w,h, 1);
	roiManager("Select",ONL_Rank_Max);
	run("Clear", "slice");
	run("Make Binary");
	ONL_Thresholded_ID = getImageID();
	//saveAs("jpeg", path2+"/4.ONL_Thresholded_ID.jpg");
	selectImage(ONL_Thresholded_ID);
			for (i=0; i<8; i++) {
			run("Dilate");
			run("Close-");
		}
	roiManager("Reset");
	run("Set Measurements...", "area display redirect=None decimal=9");
	run("Analyze Particles...", "size=1000-Infinity pixel display clear");
	ONL_Area_ID_1 = getImageID();
	//saveAs("jpeg", path2+"/5.ONL_Area_ID.jpg");
	run("Duplicate...", "title=ONL_for_INL_ID");
	ONL_for_INL_ID = getImageID();
	selectImage(ONL_for_INL_ID);
		for (i=0; i<9; i++) {
			run("Dilate");
		}
	run("Invert");
	run("Duplicate...", "title=[ONL_Dilated_ID]");
	ONL_Dilated_ID = getImageID();
	//saveAs("jpeg", path2+"/6.ONL_Dilated_ID.jpg");
	run("Duplicate...", "title=[ONL_Dilated_Crop_ID]");
	ONL_Dilated_Crop_ID = getImageID();
	//saveAs("jpeg", path2+"/7.ONL_Dilated_Crop_ID.jpg");
	selectImage(ONL_Dilated_Crop_ID);
	run("Invert");
	ONL_Dilated_Crop_ID = getImageID();
	selectImage(ONL_Segmentation_ID);
	run("Maximum...", "radius=10");
	//saveAs("jpeg", path2+"/8.ONL_Segmentation_ID After MAXIMUM.jpg");
	imageCalculator("AND create", ONL_Segmentation_ID, ONL_Dilated_Crop_ID);
	Result_ONL_Segmentation_ID_ONL_Dilated_Crop_ID = getImageID();
	//saveAs("jpeg", path2+"/9.Result_ONL_Segmentation_ID_ONL_Dilated_Crop_ID.jpg");
	selectImage(Result_ONL_Segmentation_ID_ONL_Dilated_Crop_ID);
	setAutoThreshold("Default dark");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Gaussian Blur...", "sigma=6");
	run("Make Binary");
	run("Analyze Particles...", "size=1000-Infinity pixel display clear add");
	ONL_Area_Value = getResult("Area", 0);
	ONL_Area_ID_Final = getImageID();
	//saveAs("jpeg", path2+"/10.ONL_Area_ID_Final.jpg");
	roiManager("Select", 0);
	roiManager("Rename", "ONL");
	roiManager("Save", path2+"/ONL AREA ROI.zip");
	selectImage(Merged_ID);
	roiManager("Select", 0);
	run("Labels...", "color=white font=14 show use draw bold");
	roiManager("Show All with labels");
	run("Flatten");	
	Merged_ID = getImageID();
	//
	selectImage(ONL_Total_Cells_ID);
	run("Invert");
	run("Minimum...", "radius=1");
	roiManager("Select", 0);
	run("Clear Results");
	run("Find Maxima...", "noise=5 output=Count light");
	ONL_Total_Count = getResult("Count",0);
	selectImage(ONL_Total_Cells_ID);
	roiManager("Select", 0);
	run("Find Maxima...", "noise=5 output=[Single Points] light");
	Maxima_ID = getImageID();
	selectImage(Maxima_ID);
	run("Analyze Particles...", "display add");
	roiManager("Save", path2+"/ONL CELL DENSITY ROI.zip");
	selectImage(ONL_Total_Cells_ID);
	roiManager("Select", 0);
	run("Find Maxima...", "noise=10 output=[Point Selection]");
	run("Flatten");
	ONL_Total_Count_ID = getImageID();
	roiManager("Reset");
}	

function INL_Area() {
	roiManager("Reset");
	selectImage(INL_Segmentation_ID);
	run("Maximum...", "radius=10");
	//saveAs("jpeg", path2+"/11.INL_Segmentation_ID AFTER MAXIMUM 5.jpg");
	imageCalculator("AND create", INL_Segmentation_ID, ONL_Dilated_ID);
	Result_INL_Segmentation_ID_ONL_Dilated_ID = getImageID();
	//saveAs("jpeg", path2+"/12.Result_INL_Segmentation_ID_ONL_Dilated_ID.jpg");
	selectImage(Result_INL_Segmentation_ID_ONL_Dilated_ID);
	setAutoThreshold("Default dark");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Make Binary");
	//run("Remove Outliers...", "radius=10 threshold=50 which=Dark");
	run("Fill Holes");
	run("Close-");
	run("Convert to Mask");
	Result_INL_Segmentation_ID_ONL_Dilated_ID_Processed = getImageID();
	//saveAs("jpeg", path2+"/13.Result_INL_Segmentation_ID_ONL_Dilated_ID_Processed.jpg");
	run("Clear Results");
	selectImage(Result_INL_Segmentation_ID_ONL_Dilated_ID_Processed);
	setOption("BlackBackground", false);
	run("Make Binary"); 
	Result_INL_Segmentation_ID_ONL_Dilated_ID_Processed_Masked = getImageID();
	//saveAs("jpeg", path2+"/14.Result_INL_Segmentation_ID_ONL_Dilated_ID_Processed_Masked.jpg");
	selectImage(Result_INL_Segmentation_ID_ONL_Dilated_ID_Processed_Masked);
	run("Analyze Particles...", "size=10000-Infinity pixel display clear add");
	INL_Array = newArray();
	count = roiManager("count");
	for (i=0 ; i<count; i++) {
    	roiManager("Select", i);
    	roiManager("Measure");
    	INL_Thresholded_Areas = getResult("Area",0);
    	roiManager("Rename", INL_Thresholded_Areas);
    	INL_Array_Concat = Array.concat(INL_Array,INL_Thresholded_Areas);
    	INL_Array = INL_Array_Concat;    
    	run("Clear Results");
	}
	Array.getStatistics(INL_Array_Concat, min, max, mean, std);
	INL_Area_Larger = max;
	run("Clear Results");
	for (i=0; i<count; i++) {
		roiManager("Select", i);
	 	roiManager("Measure");
	 	Area_Sorting = getResult("Area",0);
	 	if (Area_Sorting == INL_Area_Larger) {
	 		INL_Rank_Max = i;
	 		run("Clear Results");
	 	} else {
	 	}	   
	}
	newImage("INL_Area", "8-bit white", w,h, 1);
	roiManager("Select",INL_Rank_Max);
	run("Clear", "slice");
	run("Make Binary");
	run("Close-");
	run("Fill Holes");
	run("Gaussian Blur...", "sigma=6");
	run("Make Binary");
	INL_Thresholded_ID = getImageID();
	//saveAs("jpeg", path2+"/15.INL_Thresholded_ID.jpg");
	roiManager("Reset");
	run("Set Measurements...", "area display redirect=None decimal=9");
	run("Analyze Particles...", "size=1000-Infinity pixel display clear add");
	INL_Area_Value = getResult("Area", 0);
	INL_Area_ID = getImageID();
	//saveAs("jpeg", path2+"/INL_Area_ID.jpg");
	roiManager("Select", 0);
	roiManager("Rename", "INL");
	roiManager("Save", path2+"/INL AREA ROI.zip");
	selectImage(Merged_ID);
	roiManager("Select", 0);
	run("Labels...", "color=white font=14 show use draw bold");
	roiManager("Show All with labels");
	run("Flatten");	
	Merged_ID = getImageID();
	//
	selectImage(INL_Total_Cells_ID);
	run("Invert");
	run("Minimum...", "radius=1");
	roiManager("Select", 0);
	run("Clear Results");
	run("Find Maxima...", "noise=5 output=Count light");
	INL_Total_Count = getResult("Count",0);
	selectImage(INL_Total_Cells_ID);
	roiManager("Select", 0);
	run("Find Maxima...", "noise=5 output=[Single Points] light");
	Maxima_ID = getImageID();
	selectImage(Maxima_ID);
	run("Analyze Particles...", "display add");
	roiManager("Save", path2+"/INL CELL DENSITY ROI.zip");
	selectImage(INL_Total_Cells_ID);
	roiManager("Select", 0);
	run("Find Maxima...", "noise=10 output=[Point Selection]");
	run("Flatten");
	INL_Total_Count_ID = getImageID();
	roiManager("Reset");
}

function Manual_Selection() {
	roiManager("Reset");
	selectImage(Manual_Freehand_ID);
	setBatchMode("show");
	setTool("freehand");
	waitForUser("      Manual Freehand Selection", "       Select the area of interest to count cells and press OK        ");
	roiManager("Add");
	roiManager("Select", 0);
	run("Measure");
	Manual_Area_Value = getResult("Area", 0);
	roiManager("Select", 0);
	roiManager("Rename", "Manual Selection Area");
	roiManager("Save", path2+"/Freehand Selection ROI.zip");
	selectImage(Merged_ID);
	roiManager("Select", 0);
	run("Labels...", "color=white font=14 show use draw bold");
	roiManager("Show All with labels");
	run("Flatten");	
	Merged_ID = getImageID();
	roiManager("Reset");
	selectImage(Manual_Freehand_ID);
	close();
}

//-----------------------------------------------------------------------------------------------------------

function ONL_INL_Red_Function() {
	roiManager("Reset");
	selectImage(Red_ID);
	run("Subtract Background...", "rolling=5 sliding");
	Red_ID = getImageID();	
	if (Threshold_Sensitivity == "Standard") {
	imageCalculator("Add create", Red_ID, Red_ID);
	Result_of_Red_ID = getImageID();	
	selectImage(Result_of_Red_ID);
	run("Subtract Background...", "rolling=5 sliding");
	setAutoThreshold("MaxEntropy dark");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	} else {
	imageCalculator("Add create", Red_ID, Red_ID);
	Result_of_Red_ID = getImageID();	
	selectImage(Result_of_Red_ID);
	imageCalculator("Add create", Result_of_Red_ID, Result_of_Red_ID);
	Result_of_Red_ID_2x = getImageID();
	selectImage(Result_of_Red_ID_2x);
	run("Subtract Background...", "rolling=5 sliding");
	setAutoThreshold("MaxEntropy dark");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	}
	run("Fill Holes");
	run("Watershed");
	Red_ID_Thresholded = getImageID();	
	roiManager("Open", path2+"/ONL AREA ROI.zip");
	run("Clear Results");
	selectImage(Red_ID_Thresholded);
	roiManager("Select", 0);
	run("Analyze Particles...", "size=&Minimum_Cell_Size_Pixels-&Maximum_Cell_Size_Pixels pixels circularity=&Circularity_Min-&Circularity_Max show=[Overlay Outlines] display include add");
	ONL_Red_Count = nResults;
	if (ONL_Red_Count >= 1) {
		roiManager("Select", 0);
		roiManager("Delete");
		roiManager("Save", path2+"/RED CELLS ONL ROI.zip");
		run("Labels...", "color=red font=14 show bold");
		selectImage(Merged_ID);
		roiManager("Show All with labels");
		run("Flatten");	
		Merged_ID = getImageID();
		roiManager("Reset");
	} else {
		roiManager("Reset")
	}
	//INL
	roiManager("Open", path2+"/INL AREA ROI.zip");
	run("Clear Results");
	selectImage(Red_ID_Thresholded);
	roiManager("Select", 0);
	run("Analyze Particles...", "size=&Minimum_Cell_Size_Pixels-&Maximum_Cell_Size_Pixels pixels circularity=&Circularity_Min-&Circularity_Max show=[Overlay Outlines] display include add");
	INL_Red_Count = nResults;
	if (INL_Red_Count >= 1) {
		roiManager("Select", 0);
		roiManager("Delete");
		roiManager("Save", path2+"/RED CELLS INL ROI.zip");
		run("Labels...", "color=red font=14 show bold");
		selectImage(Merged_ID);
		roiManager("Show All with labels");
		run("Flatten");	
		Merged_ID = getImageID();
		roiManager("Reset");
	} else {
		roiManager("Reset")
	}
}	

function ONL_INL_Green_Function() {
	roiManager("Reset");
	selectImage(Green_ID);
	run("Subtract Background...", "rolling=5 sliding");
	Green_ID = getImageID();	
	if (Threshold_Sensitivity == "Standard") {
	imageCalculator("Add create", Green_ID, Green_ID);
	Result_of_Green_ID = getImageID();	
	selectImage(Result_of_Green_ID);
	run("Subtract Background...", "rolling=5 sliding");
	setAutoThreshold("MaxEntropy dark");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	} else {
	imageCalculator("Add create", Green_ID, Green_ID);
	Result_of_Green_ID = getImageID();	
	selectImage(Result_of_Green_ID);
	imageCalculator("Add create", Result_of_Green_ID, Result_of_Green_ID);
	Result_of_Green_ID_2x = getImageID();
	selectImage(Result_of_Green_ID_2x);
	run("Subtract Background...", "rolling=5 sliding");
	setAutoThreshold("MaxEntropy dark");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	}
	run("Fill Holes");
	run("Watershed");
	Green_ID_Thresholded = getImageID();	
	roiManager("Open", path2+"/ONL AREA ROI.zip");
	run("Clear Results");
	selectImage(Green_ID_Thresholded);
	roiManager("Select", 0);
	run("Analyze Particles...", "size=&Minimum_Cell_Size_Pixels-&Maximum_Cell_Size_Pixels pixels circularity=&Circularity_Min-&Circularity_Max show=[Overlay Outlines] display include add");
	ONL_Green_Count = nResults;
	if (ONL_Green_Count >= 1) {
		roiManager("Select", 0);
		roiManager("Delete");
		roiManager("Save", path2+"/GREEN CELLS ONL ROI.zip");
		run("Labels...", "color=green font=14 show bold");
		selectImage(Merged_ID);
		roiManager("Show All with labels");
		run("Flatten");	
		Merged_ID = getImageID();
		roiManager("Reset");
	} else {
		roiManager("Reset")
	}
	//INL
	roiManager("Open", path2+"/INL AREA ROI.zip");
	run("Clear Results");
	selectImage(Green_ID_Thresholded);
	roiManager("Select", 0);
	run("Analyze Particles...", "size=&Minimum_Cell_Size_Pixels-&Maximum_Cell_Size_Pixels pixels circularity=&Circularity_Min-&Circularity_Max show=[Overlay Outlines] display include add");
	INL_Green_Count = nResults;
	if (INL_Green_Count >= 1) {
		roiManager("Select", 0);
		roiManager("Delete");
		roiManager("Save", path2+"/GREEN CELLS INL ROI.zip");
		run("Labels...", "color=green font=14 show bold");
		selectImage(Merged_ID);
		roiManager("Show All with labels");
		run("Flatten");	
		Merged_ID = getImageID();
		roiManager("Reset");
	} else {
		roiManager("Reset")
	}
}	

function Manual_Red_Function() {
	roiManager("Reset");
	selectImage(Red_ID);
	run("Subtract Background...", "rolling=5 sliding");
	Red_ID = getImageID();	
	if (Threshold_Sensitivity == "Standard") {
	imageCalculator("Add create", Red_ID, Red_ID);
	Result_of_Red_ID = getImageID();	
	selectImage(Result_of_Red_ID);
	run("Subtract Background...", "rolling=5 sliding");
	setAutoThreshold("MaxEntropy dark");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	} else {
	imageCalculator("Add create", Red_ID, Red_ID);
	Result_of_Red_ID = getImageID();	
	selectImage(Result_of_Red_ID);
	imageCalculator("Add create", Result_of_Red_ID, Result_of_Red_ID);
	Result_of_Red_ID_2x = getImageID();
	selectImage(Result_of_Red_ID_2x);
	run("Subtract Background...", "rolling=5 sliding");
	setAutoThreshold("MaxEntropy dark");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	}
	run("Fill Holes");
	run("Watershed");
	Red_ID_Thresholded = getImageID();
	roiManager("Open", path2+"/Freehand Selection ROI.zip");
	roiManager("Select", 0);
	run("Clear Results");
	run("Analyze Particles...", "size=&Minimum_Cell_Size_Pixels-&Maximum_Cell_Size_Pixels pixels circularity=&Circularity_Min-&Circularity_Max show=[Overlay Outlines] display include add");
	Manual_Red_Count = nResults;
	if (Manual_Red_Count >= 1) {
		roiManager("Select", 0);
		roiManager("Delete");
		roiManager("Save", path2+"/RED CELLS MANUAL AREA ROI.zip");
		run("Labels...", "color=green font=14 show bold");
		selectImage(Merged_ID);
		roiManager("Show All with labels");
		run("Flatten");	
		Merged_ID = getImageID();
		roiManager("Reset");
	} else {
		roiManager("Reset")
	}
}	

function Manual_Green_Function() {
	roiManager("Reset");
	selectImage(Green_ID);
	run("Subtract Background...", "rolling=5 sliding");
	Green_ID = getImageID();	
	if (Threshold_Sensitivity == "Standard") {
	imageCalculator("Add create", Green_ID, Green_ID);
	Result_of_Green_ID = getImageID();	
	selectImage(Result_of_Green_ID);
	run("Subtract Background...", "rolling=5 sliding");
	setAutoThreshold("MaxEntropy dark");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	} else {
	imageCalculator("Add create", Green_ID, Green_ID);
	Result_of_Green_ID = getImageID();	
	selectImage(Result_of_Green_ID);
	imageCalculator("Add create", Result_of_Green_ID, Result_of_Green_ID);
	Result_of_Green_ID_2x = getImageID();
	selectImage(Result_of_Green_ID_2x);
	run("Subtract Background...", "rolling=5 sliding");
	setAutoThreshold("MaxEntropy dark");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	}
	run("Fill Holes");
	run("Watershed");
	Green_ID_Thresholded = getImageID();	
	roiManager("Open", path2+"/Freehand Selection ROI.zip");
	roiManager("Select", 0);
	run("Clear Results");
	run("Analyze Particles...", "size=&Minimum_Cell_Size_Pixels-&Maximum_Cell_Size_Pixels pixels circularity=&Circularity_Min-&Circularity_Max show=[Overlay Outlines] display include add");
	Manual_Green_Count = nResults;
	if (Manual_Green_Count >= 1) {
		roiManager("Select", 0);
		roiManager("Delete");
		roiManager("Save", path2+"/GREEN CELLS MANUAL AREA ROI.zip");
		run("Labels...", "color=green font=14 show bold");
		selectImage(Merged_ID);
		roiManager("Show All with labels");
		run("Flatten");	
		Merged_ID = getImageID();
		roiManager("Reset");
	} else {
		roiManager("Reset")
	}
}	

function Results_Array() {
	ONL_Area_mm = (sqrt(ONL_Area_Value)/Downscaled_Spatial_Scale)*(sqrt(ONL_Area_Value)/Downscaled_Spatial_Scale)/1000000;
	INL_Area_mm = (sqrt(INL_Area_Value)/Downscaled_Spatial_Scale)*(sqrt(INL_Area_Value)/Downscaled_Spatial_Scale)/1000000;
	
	selectImage(New);
	close();
	selectImage(Merged_ID);
	saveAs("jpeg", path2+"/Processed File.jpg");
	rename(name+" - Processed File");
	setBatchMode("show");
	
	run("Clear Results");
	setResult("Image", 0, name);
	setResult("Native Spatial Scale (pixels/microns)", 0, Native_Spatial_Scale);
	setResult("Threshold Sensitivity", 0, Threshold_Sensitivity);
	setResult("Minimum Cell Size (microns2)", 0, Minimum_Cell_Size_Microns);
	setResult("Maximum Cell Size (microns2)", 0, Maximum_Cell_Size_Microns);
	setResult("Minimum Cell Size (pixels2)", 0, Minimum_Cell_Size_Pixels);
	setResult("Maximum Cell Size (pixels2)", 0, Maximum_Cell_Size_Pixels);
	setResult("Cell Roundness", 0, Cell_Roundness);
	setResult("ONL Area (mm2)", 0, ONL_Area_mm);
	setResult("INL Area (mm2)", 0, INL_Area_mm);
	setResult("Manual Area (mm2)", 0, Manual_Area_Value);
	setResult("Red Cells ONL (count)", 0, ONL_Red_Count);
	setResult("Red Cells INL (count)", 0, INL_Red_Count);
	setResult("Red Cells Manual Area (count)", 0, Manual_Red_Count);
	setResult("Green Cells ONL (count)", 0, ONL_Green_Count);
	setResult("Green Cells INL (count)", 0, INL_Green_Count);
	setResult("Green Cells Manual Area (count)", 0, Manual_Green_Count);
	Result_Array = newArray("Image", "Native Spatial Scale (pixels/microns)", "Threshold Sensitivity", "Minimum Cell Size (microns)", "Maximum Cell Size (microns)", "Cell Roundness", "ONL Area (mm2)", "INL Area (mm2)", "Manual Area (mm2)", "Red Cells ONL (count)", "Red Cells INL (count)", "Red Cells Manual Area (count)", "Green Cells ONL (count)", "Green Cells INL (count)", "Green Cells Manual Area (count)");
	saveAs("Results", path2+"/Results.xls");
	selectWindow("Results");
	run("Close");
	run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
	roiManager("Reset");
	
}		
