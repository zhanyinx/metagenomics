
params.date = new java.util.Date().format('yyMMdd')


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    INCLUDES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/


include {metaphlan} from '../modules/local/metaphlan/main.nf'
include {add_mean_sd_healthy} from '../modules/local/control/main.nf'
include {filtering} from '../modules/local/filtering/main.nf'
include {barplot} from '../modules/local/plot/main.nf'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Channel preprocessing
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

input_channel = extract_csv(file(params.input))
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    sub Workflow
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow METAGENOMICS {
    metaphlan(input_channel)
    add_mean_sd_healthy(metaphlan.out.profile)
    filtering(add_mean_sd_healthy.out)
    barplot(filtering.out)
}


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Functions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
// extract channels from input annotation sample sheet 
def extract_csv(csv_file) {
    // check that the sample sheet is not 1 line or less, because it'll skip all subsequent checks if so.
    file(csv_file).withReader('UTF-8') { reader ->
        def line, numberOfLinesInSampleSheet = 0;
        while ((line = reader.readLine()) != null) {
            numberOfLinesInSampleSheet++
            if (numberOfLinesInSampleSheet == 1){
                def requiredColumns = ["patient", 'sample_path', 'population']
                def headerColumns = line
                if (!requiredColumns.every { headerColumns.contains(it) }) {
                    log.error "Header missing or CSV file does not contain all of the required columns in the header: ${requiredColumns}"
                    System.exit(1)
                }
            }
        }
        
        if (numberOfLinesInSampleSheet < 2) {
            log.error "Provided SampleSheet has less than two lines. Provide a samplesheet with header and at least a sample."
            System.exit(1)
        }
    }

    Channel.from(csv_file)
        .splitCsv(header: true)
        .map { row ->
                [row.patient, row.sample_path, row.population]
        }
}