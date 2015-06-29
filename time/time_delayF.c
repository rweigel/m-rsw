/* Usage: x.bin y.bin t.bin N Lf No Nd

      N: 
      Lf: 
      No: 

      Reads a binary file of IEEE 64-bit little-endian floats starting
      at value Ns and ending at Nr+Ns-1 and outputs Nr/Na values.  NaN
      values are omitted from averages.  If infile.bin does not have
      enough values, NaNs are provided so that Nr/Na values are always
      returned.  Nr/Na and Nr/Np must be integer; no checks are make
      to ensure this.

      Example: If infile.bin contains the values 0.0, 1.0, NaN, 3.0, then
               bin2bin infile.bin 0 2 2 2 0 gives (1.0)/1.0
               bin2bin infile.bin 0 3 3 3 0 gives (1.0+3.0)/2.0

       sudo mount -t tmpfs none /tmp/ramdisk -o size=8g

*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

int main( int argc, char * argv[] ) {

   int i = 0;
   int k = 0;
   int kt = 0;
   int j = 0;
   int debug = 0;

   long N;
   int Lf;
   int No;
   int Ndump;

   double sum;
   double ave;
   double sum_last;
   double *data_in;
   double *data_out;
   double *data_outT;
   int recSize;

   recSize = sizeof(double);
   //double nan=0.0;
   //nan = nan/nan; // To avoid compiler warning.

   int rowwithnan;
   int number_in;
   int number_out;

   FILE *file_in;
   FILE *file_out;
   FILE *file_outT;

   if ((file_in = fopen(argv[1],"r")) == NULL){
     fprintf(stderr,"Cannot open input data file %s. Aborting.\n",argv[1]);
     return 1;
   }
   if ((file_out = fopen(argv[2],"w")) == NULL){
     fprintf(stderr,"Cannot open output data file %s. Aborting.\n",argv[2]);
     return 1;
   }
   if ((file_outT = fopen(argv[3],"w")) == NULL){
     fprintf(stderr,"Cannot open output data file %s. Aborting.\n",argv[3]);
     return 1;
   }

   N  = atoi(argv[4]);
   Lf = atoi(argv[5]);
   No = atoi(argv[6]);
   //   Ndump = atoi(argv[6]);
   Ndump = 1;

   //   fprintf(stdout,"Start malloc\n");
   data_in = (double *)malloc(N*recSize);
   data_out = (double *)malloc(Ndump*Lf*recSize);
   data_outT = (double *)malloc(N*recSize);
   //   fprintf(stdout,"End malloc\n");

   if (data_in == NULL){
     fprintf(stdout,"Error allocating memory\n");
   }
   if (data_out == NULL){
     fprintf(stdout,"Error allocating memory\n");
   }
   if (data_outT == NULL){
     fprintf(stdout,"Error allocating memory\n");
   }

   if (debug) {
     fprintf(stdout,"Input file: %s\n",argv[1]);
     fprintf(stdout,"Output file: %s\n",argv[2]);
     fprintf(stdout,"Output file T: %s\n",argv[3]);
     fprintf(stdout,"N: %d\n",N);
     fprintf(stdout,"Lf: %d\n",Lf);
     fprintf(stdout,"N*Lf*8: %d\n",N*Lf*8);
     fprintf(stdout,"No: %d\n",No);
   }
   
   if (debug) {
     fprintf(stdout,"Starting Read\n");
   }
   number_in  = fread(data_in, recSize, N, file_in);
   if (debug) {
     fprintf(stdout,"Finished Read\n");
     fprintf(stdout,"number_in=%d\n",number_in);
   }

   if (debug) {
     fprintf(stdout,"Start Loop\n");
   }

   for (j = 0;j<N-Lf;j++) {
     rowwithnan = 0;
     for (i = 0;i<Lf;i++) {
       if (isnan(data_in[j+i]) == 1) {
	 if (debug)
	   fprintf(stdout,"data_out[%d]=NaN\n",i+k*Lf);	 
	 rowwithnan = 1;
	 continue;
       } else {
	 data_out[i+k*Lf] = data_in[j+i];
	 if (debug)
	   fprintf(stdout,"data_out[%d]=%f ... %d\n",i+k*Lf,data_out[i+k*Lf],kt);
       }
     }

     if (rowwithnan == 0) {
       data_outT[kt] = j;
       if (debug)
	 fprintf(stdout,"data_outT[%d]=%f\n",kt,data_outT[kt]);
       k = k+1;
       kt = kt+1;
     }
     //     if ((k > 0) & (k % Ndump == 0)) {
     //     if (k % Ndump == 0) {
     if (k > 0) {
       if (debug) 
	 fprintf(stdout,"Dumping k=%d\n",k);
       number_out = fwrite(data_out, recSize, Lf*k, file_out);
       k = 0;
     }
   }

   if (debug) {
     fprintf(stdout,"End Loop\n");
     fprintf(stdout,"k=%d\n",k);
     fprintf(stdout,"Start last writes\n");
   }

   // Last (N-k) rows will not be complete, so read program should ignore them
   if (k != 0) {
     number_out = fwrite( data_out, recSize, Lf*k, file_out );
   }
   number_out = fwrite( data_outT, recSize, kt, file_outT );

   if (debug) {
     fprintf(stdout,"End last writes\n");
   }

   free(data_in);
   free(data_out);
   free(data_outT);
   fclose(file_in);   
   fclose(file_out);   
   fclose(file_outT);   

   return 0;
}
