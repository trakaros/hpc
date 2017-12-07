/*
* This sample implements a separable convolution 
* of a 2D image with an arbitrary filter.
*/

#include <stdio.h>
#include <stdlib.h>
#include <cuda.h>
#include <cuda_runtime_api.h>
unsigned int filter_radius;


#define NUM_THREADS imageH*imageW
#define NUM_BLOCKS 1

cudaError_t code;

#define CUDA_ERROR_CHECK(n) \
   code = cudaGetLastError(); \
   if ( code != cudaSuccess ) {\
    printf("**** Error at num %d cudaGetLastError().*********\n", n ); \
    printf("Type of error: %s\n", cudaGetErrorString( code )); \
   }

//#define FILTER_LENGTH 	(2 * filter_radius + 1)
#define FILTER_LENGTH 9//33

#define ABS(val)  	((val)<0.0 ? (-(val)) : (val))
#define accuracy  	0.00005 

 

__constant__  __device__ float d_Filter[FILTER_LENGTH];

////////////////////////////////////////////////////////////////////////////////
// Reference row convolution filter
////////////////////////////////////////////////////////////////////////////////
void convolutionRowCPU(float *h_Dst, float *h_Src, float *h_Filter, 
                       int imageW, int imageH, int filterR) {

  int x, y, k;
                      
  for (y = 0; y < imageH; y++) {
    for (x = 0; x < imageW; x++) {
      float sum = 0;

      for (k = -filterR; k <= filterR; k++) {
        int d = x + k;

        if (d >= 0 && d < imageW) {
          sum += h_Src[y * imageW + d] * h_Filter[filterR - k];
        }     

        h_Dst[y * imageW + x] = sum;
      }
    }
  }
        
}




////////////////////////////////////////////////////////////////////////////////
// Reference column convolution filter
////////////////////////////////////////////////////////////////////////////////
void convolutionColumnCPU(	
          float *h_Dst, 
          float *h_Src, 
          float *h_Filter,
          int imageW, 
          int imageH, 
          int filterR) 			{

  int x, y, k;
  


  for (y = 0; y < imageH; y++) {
    for (x = 0; x < imageW; x++) {
      float sum = 0;

      for (k = -filterR; k <= filterR; k++) {
        int d = y + k;

        if (d >= 0 && d < imageH) {
          sum += h_Src[d * imageW + x] * h_Filter[filterR - k];
        }   
        h_Dst[y * imageW + x] = sum;
      }
    }
  }    
}


/*
 * GPU convolution Rows
 */
__global__ void convolutionRowGPU(
          float *d_Dst, 
          float *d_Src, 
          /*float *d_Filter,*/
          int imageW, 
          int imageH, 
          int filterR)                           
{
	  float sum=0;
          int x, d, k;          
          x = threadIdx.x + blockDim.x * blockIdx.x;
          
          for (k = -filterR; k <= filterR; k++) {  
            d = x%imageW + k;
            
            if (d >= 0 && d < imageW) {
              sum += d_Src[x + k] * d_Filter[filterR - k];
            }
            d_Dst[x] = sum;
          
          }


}

/*
 * GPU convolution Columns
 */
__global__ void convolutionColumnGPU(
          float *d_Dst, 
          float *d_Src, 
          /*float *d_Filter,*/
          int imageW, 
          int imageH, 
          int filterR)                           
{
        
        float sum=0;
          int x, d, k;          
          x = threadIdx.x + blockDim.x * blockIdx.x;
          
          for (k = -filterR; k <= filterR; k++) {  
            d = x/imageW + k;
            
            if (d >= 0 && d < imageH) {
              sum += d_Src[d * imageW + x%imageW] * d_Filter[filterR - k] ;
            }
            d_Dst[x] = sum;
          
          }
     
}

__global__ void convolutionTileRowGPU (

)  

{

//int i = blockIdx.x * blockDim.x + threadIdx.x;




}



__global__ void convolutionTileColumnGPU (

)  

{



}

////////////////////////////////////////////////////////////////////////////////
// Main program
////////////////////////////////////////////////////////////////////////////////
int main(int argc, char **argv) {
    
    float *h_Filter, *h_Input, *h_Buffer, *h_OutputCPU, *h_OutputGPU, *d_Input,
*d_Output_GPU, *d_Buffer  /*,*d_Filter*/;
    
    int pointsThatDiffer = 0;
    int imageW;
    int imageH;
    unsigned int i;


    	
    // Ta imageW, imageH ta dinei o xrhsths kai thewroume oti einai isa,
    // dhladh imageW = imageH = N, opou to N to dinei o xrhsths.
    // Gia aplothta thewroume tetragwnikes eikones.  
   if (argc < 3)  {
      printf("Few arguments. Run as ./<name>  <image_size> <filter_radius>,where <image_size> should be a power of two and greater than 2*filter_radius+ 1\n");
      return -1;
   } 

   if ( strlen(argv[1]) == 0 ) {
      printf("Error at argv[1]. Please give the size of image as 1st argument(e.g. ./exe 100 5\n"); 
      return -1;
    }
    imageW = atoi(argv[1]);
    imageH = imageW;

 
    if ( strlen(argv[2]) == 0 ) {
      printf("Error at argv[1]. Please give the filter radius  as 2nd argument(e.g. ./exe 100\n"); 
      return -1;
    }
    filter_radius = atoi(argv[2]);


    printf("Image Width x Height = %i x %i\n\n", imageW, imageH);
    printf("Allocating and initializing host arrays...\n");
    // Tha htan kalh idea na elegxete kai to apotelesma twn malloc...
    h_Filter    = (float *)malloc(FILTER_LENGTH * sizeof(float));
    h_Input     = (float *)malloc(imageW * imageH * sizeof(float) );
    h_Buffer    = (float *)malloc(imageW * imageH * sizeof(float));
    h_OutputCPU = (float *)malloc(imageW * imageH * sizeof(float));
    
    /// *** EDITED  ***//
    cudaMalloc( (void **)&d_Input, imageW * imageH * sizeof(float) );
    //cudaMalloc( (void **)&d_Filter, FILTER_LENGTH * sizeof(float) );
    cudaMalloc( (void **)&d_Output_GPU,  imageW * imageH * sizeof(float) );
    cudaMalloc( (void **)&d_Buffer,  imageW * imageH * sizeof(float) );
    
    h_OutputGPU = (float *)malloc(imageW * imageH * sizeof(float));
    if ( h_Filter == NULL || h_Input == NULL ||  h_Buffer == NULL ||
h_OutputCPU==NULL || h_OutputGPU == NULL) {
      printf("Error allocating host or device\n"); 
    } 

   
   /*
    * tsekare an uparxoun sfalmata
    */
    
    // to 'h_Filter' apotelei to filtro me to opoio ginetai to convolution kai
    // arxikopoieitai tuxaia. To 'h_Input' einai h eikona panw sthn opoia ginetai
    // to convolution kai arxikopoieitai kai auth tuxaia.

    srand(200);

    for (i = 0; i < FILTER_LENGTH; i++) {
        h_Filter[i] = (float)(rand() % 16);
    }

    for (i = 0; i < (unsigned int)imageW * imageH; i++) {
        h_Input[i] = (float)rand() / ((float)RAND_MAX / 255) + (float)rand() / (float)RAND_MAX;
    }

    
    cudaMemcpy(d_Input,h_Input,imageW*imageH*sizeof(float),cudaMemcpyHostToDevice);
    CUDA_ERROR_CHECK(1);
    
    //cudaMemcpy(d_Filter,h_Filter,FILTER_LENGTH*sizeof(float),cudaMemcpyHostToDevice);
   
    code = cudaMemcpyToSymbol(
       d_Filter,
       h_Filter,
       FILTER_LENGTH*sizeof( float )
       //0,
       //cudaMemcpyHostToDevice
    ); if (code != cudaSuccess) printf("Error copying from host Memory to Constant Memory!\n");
     

    CUDA_ERROR_CHECK(2);

    // To parakatw einai to kommati pou ekteleitai sthn CPU kai me vash auto prepei na ginei h sugrish me thn GPU.
    printf("CPU computation...\n");

    convolutionRowCPU(h_Buffer, h_Input, h_Filter, imageW, imageH, filter_radius); // convolution kata grammes
    convolutionColumnCPU(h_OutputCPU, h_Buffer, h_Filter, imageW, imageH, filter_radius);//convolution kata sthles    

    convolutionRowGPU<<<NUM_BLOCKS , NUM_THREADS>>>(d_Buffer,
d_Input/*,d_Filter*/, imageH, imageW, filter_radius);
    
    cudaThreadSynchronize();//barrier of host     
    CUDA_ERROR_CHECK(3);
         
    convolutionColumnGPU<<<NUM_BLOCKS , NUM_THREADS>>>(d_Output_GPU, d_Buffer,
 /*d_Filter,*/ imageH, imageW, filter_radius);
    cudaThreadSynchronize();//barrier of host
    CUDA_ERROR_CHECK(4);





    //return data to host by copying the from global memory to host memory
    cudaMemcpy(h_OutputGPU, d_Output_GPU, imageW * imageH * sizeof(float),cudaMemcpyDeviceToHost);
    CUDA_ERROR_CHECK(5);

    //now compare host results VS device results. Is GPU same as CPU?!
    for (i = 0; i < (unsigned int)imageW * imageH; i++) {
        if(ABS(h_OutputCPU[i] - h_OutputGPU[i]) > accuracy){
          pointsThatDiffer = 1;
          printf("The difference between the %dnth element is larger than accuracy. \n CPU: %g GPU %g differece: %.15g \nNow exiting..\n", i,h_OutputCPU[i] ,h_OutputGPU[i], ABS(h_OutputGPU[i] - h_OutputCPU[i])  );
	  break;
        }
     }
     if (pointsThatDiffer == 0)
       printf("******************** Correct: GPU output is the same as CPU output *************\n");
     else
       printf("******************** Error: GPU output differs from CPU output!!!  *************\n");

    
    // free all the allocated memory
    free(h_OutputCPU); cudaFree(d_Output_GPU);
    free(h_Buffer); cudaFree(d_Buffer);
    free(h_Input); cudaFree(d_Input);
    free(h_Filter); //cudaFree(d_Filter);

    
    // Do a device reset just in case... Bgalte to sxolio otan ylopoihsete CUDA
    cudaDeviceReset();
    CUDA_ERROR_CHECK(6);

    return 0;
}
