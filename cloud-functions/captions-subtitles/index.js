const functions = require('@google-cloud/functions-framework');
const { TranscoderServiceClient } =
	require('@google-cloud/video-transcoder').v1;

const projectId = 'master-sector-430909-i0';
const location = 'us-central1';
const uri = 'gs://transcoder-destination/';
const topic = "projects/master-sector-430909-i0/topics/transcoder-topic";

// Instantiates a transcoder client
const transcoderServiceClient = new TranscoderServiceClient();

functions.http('captionsAndSubtitlesFunction', async (req, res) => {
	const body = req.body;
	const request = {
		parent: transcoderServiceClient.locationPath(projectId, location),
		job: {
			inputUri: uri + (body.fileName.toString().split(".")[0]) + "/" + body.name,
			outputUri: uri + (body.fileName.toString().split(".")[0]) + "/",
			config: {
				inputs: [
					{
						key: 'input0',
						uri: inputVideoUri,
					},
					{
						key: 'subtitle_input_en',
						uri: inputSubtitles1Uri,
					},
					{
						key: 'subtitle_input_es',
						uri: inputSubtitles2Uri,
					},
				],
				editList: [
					{
						key: 'atom0',
						inputs: ['input0', 'subtitle_input_en', 'subtitle_input_es'],
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
					{
						key: 'vtt-stream-en',
						textStream: {
							codec: 'webvtt',
							languageCode: 'en-US',
							displayName: 'English',
							mapping: [
								{
									atomKey: 'atom0',
									inputKey: 'subtitle_input_en',
								},
							],
						},
					},
					{
						key: 'vtt-stream-es',
						textStream: {
							codec: 'webvtt',
							languageCode: 'es-ES',
							displayName: 'Spanish',
							mapping: [
								{
									atomKey: 'atom0',
									inputKey: 'subtitle_input_es',
								},
							],
						},
					},
				],
				muxStreams: [
					{
						key: 'sd-hls-fmp4',
						container: 'fmp4',
						elementaryStreams: ['video-stream0'],
					},
					{
						key: 'audio-hls-fmp4',
						container: 'fmp4',
						elementaryStreams: ['audio-stream0'],
					},
					{
						key: 'text-vtt-en',
						container: 'vtt',
						elementaryStreams: ['vtt-stream-en'],
						segmentSettings: {
							segmentDuration: {
								seconds: 6,
							},
							individualSegments: true,
						},
					},
					{
						key: 'text-vtt-es',
						container: 'vtt',
						elementaryStreams: ['vtt-stream-es'],
						segmentSettings: {
							segmentDuration: {
								seconds: 6,
							},
							individualSegments: true,
						},
					},
				],
				manifests: [
					{
						fileName: 'manifest.m3u8',
						type: 'HLS',
						muxStreams: [
							'sd-hls-fmp4',
							'audio-hls-fmp4',
							'text-vtt-en',
							'text-vtt-es',
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
