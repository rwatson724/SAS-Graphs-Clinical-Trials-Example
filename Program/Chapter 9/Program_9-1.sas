/****************************************************************************************
Program:          Program_9-1.sas

SAS Version:      SAS Enterprise Guide 7.15 (SAS 9.4m5)
Developer:        Richann Watson 
Date:             2020-04-14
Purpose:          Produce outputs for SAS® Graphics for Clinical Trials by Example book. 
Operating Sys:    Windows 10

Macros:           NONE

Input:            NONE

Output:           NONE

Comments:         Use CustomSapphire style that was provided by SAS press
                  Note CustomSapphire is not provided with SAS but rather created 
                  specifically for SAS Press books
----------------------------------------------------------------------------------------- 
****************************************************************************************/

/*******************************************/
/*** BEGIN SECTION TO BE UPDATED BY USER ***/
/*******************************************/
%include "C:\Users\gonza\Desktop\GTL_Book_with_Kriss_Harris\Example Code and Data\Program\Chapter 9\styles\CustomSapphire.sas";
/*****************************************/
/*** END SECTION TO BE UPDATED BY USER ***/
/*****************************************/

proc template;
   source STYLES.SAPPHIRE / expand;
run;

proc template;
   source CustomSapphire / expand;
run;
