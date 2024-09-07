// Add the remaining fields from frontend to custom metadata which will be received by cloud function event

const functions = require('@google-cloud/functions-framework');
const { TranscoderServiceClient } =
	require('@google-cloud/video-transcoder').v1;

const projectId = 'master-sector-430909-i0';
const location = 'us-central1';
const uri = 'gs://transcoder-destination/';
const topic = "projects/master-sector-430909-i0/topics/transcoder-topic";

// Instantiates a transcoder client
const transcoderServiceClient = new TranscoderServiceClient();

functions.http('overlayCreationFunction', async (req, res) => {
	const body = req.body;
	const request = {
		parent: transcoderServiceClient.locationPath(projectId, location),
		job: {
			inputUri: uri + (body.fileName.toString().split(".")[0]) + "/" + body.name,
			outputUri: uri + (body.fileName.toString().split(".")[0]) + "/",
			config: {
				elementaryStreams: [
					{
						key: 'video-stream0',
						videoStream: {
							h264: {
								heightPixels: 360,
								widthPixels: 640,
								bitrateBps: 550000,
								frameRate: 60,
							},
						},
					},
					{
						key: 'audio-stream0',
						audioStream: {
							codec: 'aac',
							bitrateBps: 64000,
						},
					},
				],
				muxStreams: [
					{
						key: body.name.toString().split(".")[0],
						container: body.name.toString().split(".")[1],
						elementaryStreams: ['video-stream0', 'audio-stream0'],
					},
				],
				overlays: [
					{
						image: {
							uri: uri + body.imageName,
							resolution: {
								x: 1,
								y: 0.5,
							},
							alpha: 1.0,
						},
						animations: [
							{
								animationStatic: {
									xy: {
										x: 0,
										y: 0,
									},
									startTimeOffset: {
										seconds: 0,
									},
								},
							},
							{
								animationEnd: {
									startTimeOffset: {
										seconds: 10,
									},
								},
							},
						],
					},
				],
				pubsubDestination: {
					topic: topic
				}
			}
		},
	};

	// Run request
	const [response] = await transcoderServiceClient.createJob(request);
	console.log(response);
	res.status(200).send({ "state": "success", "msg": "Job created successfully !" });
});
