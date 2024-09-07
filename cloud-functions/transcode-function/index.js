const functions = require('@google-cloud/functions-framework');
const { TranscoderServiceClient } =
  require('@google-cloud/video-transcoder').v1;

const projectId = 'master-sector-430909-i0';
const location = 'us-central1';
const inputUri = 'gs://transcoder-source/';
const outputUri = 'gs://transcoder-destination/';
const preset = 'preset/web-hd';
const topic = "projects/master-sector-430909-i0/topics/transcoder-topic";

// Instantiates a transcoder client
const transcoderServiceClient = new TranscoderServiceClient();

functions.cloudEvent('transcodeVideoFunction', async (cloudEvent) => {
  const file = cloudEvent.data;
  const request = {
    parent: transcoderServiceClient.locationPath(projectId, location),
    job: {
      inputUri: inputUri + file.name,
      outputUri: outputUri + (file.name.toString().split(".")[0]) + "/",
      templateId: preset,
      //config: {
      //  pubsubDestination: {
      //    topic: topic
      //  }
      //}
    },
  };

  // Run request
  const [response] = await transcoderServiceClient.createJob(request);
  console.log(response);
  //res.send(response);
});
