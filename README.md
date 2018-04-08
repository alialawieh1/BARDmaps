# BARDmaps
BARDmaps
Installation and run time instructions

This work include different files that need pre-configuration and a software installation to work:
	TableData.m file to generate the pre-processed data: this needs as input 3 excel files:
	Original excel file containing the data in the format of the file 'SampleInitialData.xlsx'. the order of information in the excel sheet is crucial for the code to work correctly.
 	Antimicrobial excel file in the format of the file 'antimicrobialList.xlsx'
 	Bacteria excel file in the format of the file 'bacteriaList.xlsx'
 	DistInfo.m files to generate the distribution similarity among different bacteria-antimicrobial combinations for different site conditions. It only needs the TableData.m to be executed first in the same directory of these two files.
 
GUI for the structural model:
	Download graphviz-2.30.1. For the dotty application, to get rid of the circle on the edge, go to the file dotty.lefty in the folder Graphviz2.30\lib\lefty\ and edit the file dotty.lefty by changing the value of 'edgehandles' = 1; to 'edgehandles' = 0; should be on line 110 or somewhere close to that.
	Make sure that TableData.m is already executed in the same directory of the ABResistance.m file.
	In the ABResistance.m file change the paths:
	C:\Users\Downloads\..\bin: Replace it with the path where you installed the bin folder in graphviz
	C:\Users\Documents\Matlab: Replace it with the path where you want the output file to be set. This output file is automatically generated to draw the graph so the user should not worry about, but you just have to indicate where you want the GUI to create it.
	GUI for HMM validation and prediction: just make sure that TableData.m is already executed in the same directory of the ABResistanceHMM.m file.

IMPORTANT: If the antimicrobial, bacteria, or country of interest is not mentioned in the GUI, you should add them as written in the InitialData excel you have in both the GUI and the excel files of bacteriaList and antimocrobialList.

The collected data from papers are recorded in excel sheets in the following format that shows the relevant features that allow the study of the bacteria antimicrobial relation.
The excel file that contains the collected data is named “SampleInitialData.xlsx”.
The required fields in each entry are:
	Reference: indicates the paper number (each paper has a unique number that maps to it). It is indicated to refer to it in case we need further information, and to know the source of the information.
	Location: represents the country from which the samples were taken.
	Start month, start year, end month, and end year: since the antimicrobial resistance doesn’t change from day to day, we approximated the dates in a way to have start month and end month to be either 1 (January).
	Site: reflects the site from where the samples were taken; like urine, blood sample and CSF, clinical samples, etc…
	Studied bacteria: indicates the name of the studied bacteria
	Number of studied isolates: represents the number of the studied samples for a given bacteria and antimicrobial and for the above listed features.
	Studied antimicrobial: mentions the name of the studied antimicrobial on the samples.
	Number of resistant isolates: contains the number of isolates that show resistance on the mentioned antimicrobial.
	Percentage of resistant isolates: it is the percentile quotient of the number of resistant isolates over the studied number of isolates.

The MATLAB file “TableData.m” generates the matrices of the data, the bacteria, and the antimicrobial using the excel files “SampleInitialData.xlsx”, “bacteriaList.xlsx”, and “antimicrobialList.xlsx”. The generated matrices are saved in the file “DatabaseTable.mat”.

Computational Models
We implemented two models; the structural and the behavioral model respectively in the files “ABResistance.m” and “ABResistanceHMM.m”.

Apart from the GUI, but using the file “DatabaseTable.mat”, and based on the behavior of the AMR over years, we can track relations among antimicrobial-bacteria combinations that could lead to the discovery of similar genetic background, pattern recognition, for the related bacteria behaviors against antimicrobial. In order to visualize the antimicrobial-bacteria combinations and relations we did the following:
	1.For each possible combination of one bacteria and one antimicrobial we recorded the edges values into vectors. Each vector represents the edges of a specified combination.
	2.Then the dendrogram for the vectors having same lengths is plotted. The minimum acceptable length to do the comparison is four, so we neglected the combinations having smaller vector length.

These steps are executed from the file “DistInfo.m”.
