/* Look for hotspots in manhattan*/
	PROC IMPORT OUT= WORK.pop 
            DATAFILE= "C:\Users\dmw63\Desktop\My documents h\TEACHING\CLUSTERS\SATSCAN\NYS_SES_Data_region.dbf" 
            DBMS=DBF REPLACE;
     GETDELETED=NO;
RUN;
/*READ IN SHAPE FILE WITH DATA FOR SATSCAN--use .dbf file*/
proc mapimport  out=nymap datafile="C:\Users\dmw63\Desktop\My documents h\TEACHING\CLUSTERS\SATSCAN\NYSCancer_region.dbf";
run;
proc mapimport  out=pop datafile="C:\Users\dmw63\Desktop\My documents h\TEACHING\CLUSTERS\SATSCAN\NYS_SES_Data_region.dbf";
run;
/*FORMAT SHAPE FILE*/
proc mapimport  out=coord datafile="C:\Users\dmw63\Desktop\My documents h\TEACHING\CLUSTERS\SATSCAN\NYSCancer_region.shp";
run;
data nymap2; merge nymap pop ;
by dohregion;
if f_tot=0 then delete;
inc_breast=obreast/f_tot*100000; 
run;
proc mapimport  out=coord datafile="C:\Users\dmw63\Desktop\My documents h\TEACHING\CLUSTERS\SATSCAN\NYSCancer_region.shp";
run;
data man1; set nymap2;
	where substr(dohregion,1,5)="36061";
	log_offset=log(ebreast);
	obs_inc=obreast/ebreast;
run;
proc sort data=man1;
	by dohregion;
run;
/*INput file for SATSCAN*/
PROC EXPORT DATA= WORK.MAN1 
            OUTFILE= "C:\Users\dmw63\Desktop\My documents h\TEACHING\CLUSTERS\SATSCAN\MANHATTAN SUBSET CANCER.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;



proc genmod data=man1 ;
 model obreast = hh_size /
	offset=log_offset dist=poisson link=log;
 output out=pred1 predicted=pred_cases_breast;
run;

data pred2; set pred1;
	rr_age_sex=obreast/ebreast;
	rr_age_sex_hh=obreast/pred_cases_breast;
run;
PROC EXPORT DATA= WORK.pred2 
            OUTFILE= "C:\Users\dmw63\Desktop\My documents h\TEACHING\CLUSTERS\SATSCAN\MANHATTAN SUBSET CANCER adj.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;
data man_coord; set coord;
		where substr(dohregion,1,5)="36061"; /*restrict map file to manhattan*/
		run;
		/*compare observed and predicted incidence*/
		proc sgplot data=pred2;
			scatter x=rr_age_sex y=rr_age_sex_hh;
			yaxis min=0 max=3.5;
			xaxis min=0 max=3.5;
		run;
			title "Observed over expected, based on age/sex adjustment";
	proc gmap map=man_coord /*map file for manhattab*/
						data=pred2      /*data file*/; 
					 id dohregion; 
					 choro rr_age_sex/		/*shade clusters*/
							 /*discrete*/ coutline=ltgray /*annotate=anno*/; 
					run; quit; 
					goptions reset=all;
		goptions reset=all;
		title "Observed over expected, based on age/sex/SES adjustment";
	proc gmap map=man_coord /*map file for manhattab*/
						data=pred2     /*data file*/; 
					 id dohregion; 
					 choro rr_age_sex_hh/		/*shade clusters*/
							 /*discrete*/ coutline=ltgray /*annotate=anno*/; 
					run; quit; 
					goptions reset=all;


