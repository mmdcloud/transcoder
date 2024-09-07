const functions = require('@google-cloud/functions-framework');
const { TranscoderServiceClient } =
	require('@google-cloud/video-transcoder').v1;

const projectId = 'master-sector-430909-i0';
const location = 'us-central1';
const outputUri = 'gs://transcoder-destination/';
const topic = "projects/master-sector-430909-i0/topics/transcoder-topic";

function calcOffsetNanoSec(offsetValueFractionalSecs) {
	if (offsetValueFractionalSecs.toString().indexOf('.') !== -1) {
		return (
			1000000000 *
			Number('.' + offsetValueFractionalSecs.toString().split('.')[1])
		);
	}
	return 0;
}

// Instantiates a transcoder client
const transcoderServiceClient = new TranscoderServiceClient();

functions.http('concatenateMultipleInputsFunction', async (req, res) => {

	const body = req.body;

	const inputUri1 = 'gs://my-bucket/my-video-file1';
	const startTimeOffset1 = 0;
	const endTimeOffset1 = 8.1;
	const inputUri2 = 'gs://my-bucket/my-video-file2';
	const startTimeOffset2 = 3.5;
	const endTimeOffset2 = 15;

	const startTimeOffset1Sec = Math.trunc(body.startTimeOffset1);
	const startTimeOffset1NanoSec = calcOffsetNanoSec(body.startTimeOffset1);
	const endTimeOffset1Sec = Math.trunc(body.endTimeOffset1);
	const endTimeOffset1NanoSec = calcOffsetNanoSec(body.endTimeOffset1);

	const startTimeOffset2Sec = Math.trunc(body.startTimeOffset2);
	const startTimeOffset2NanoSec = calcOffsetNanoSec(body.startTimeOffset2);
	const endTimeOffset2Sec = Math.trunc(body.endTimeOffset2);
	const endTimeOffset2NanoSec = calcOffsetNanoSec(body.endTimeOffset2);

	const request = {
		parent: transcoderServiceClient.locationPath(projectId, location),
		job: {
			outputUri: outputUri,
			config: {
				inputs: [
					{
						key: 'input1',
						uri: inputUri1,
					},
					{
						key: 'input2',
						uri: inputUri2,
					},
				],
				editList: [
					{
						key: 'atom1',
						inputs: ['input1'],
						startTimeOffset: {
							seconds: startTimeOffset1Sec,
							nanos: startTimeOffset1NanoSec,
						},
						endTimeOffset: {
							seconds: endTimeOffset1Sec,
							nanos: endTimeOffset1NanoSec,
						},
					},
					{
						key: 'atom2',
						inputs: ['input2'],
						startTimeOffset: {
							seconds: startTimeOffset2Sec,
							nanos: startTimeOffset2NanoSec,
						},
						endTimeOffset: {
							seconds: endTimeOffset2Sec,
							nanos: endTimeOffset2NanoSec,
						},
					},
				],
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
						key: 'sd',
						container: 'mp4',
						elementaryStreams: ['video-stream0', 'audio-stream0'],
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
