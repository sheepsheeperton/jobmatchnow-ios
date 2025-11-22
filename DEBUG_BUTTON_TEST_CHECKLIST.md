# Debug Button Test Checklist

## Expected Console Output Flow

When you press the "Use sample résumé (debug)" button, you should see the following in Xcode console:

### 1. Button Press
```
========================================
[DEBUG BUTTON] Sample resume button pressed
========================================
[DEBUG BUTTON] Found bundled sample resume at: file:///path/to/SampleResume.pdf
[DEBUG BUTTON] File exists: true
[DEBUG BUTTON] Calling shared upload function...
```

### 2. Upload Process
```
[UploadResumeView] uploadSelectedFile() called with URL: file:///path/to/SampleResume.pdf
[UploadResumeView] Setting isUploading = true
[UploadResumeView] Attempting to access security-scoped resource
[UploadResumeView] Security-scoped access granted: false (normal for bundle resources)
[UploadResumeView] File exists at path: true
[UploadResumeView] File size: [size] bytes
[UploadResumeView] Starting API upload call to /api/resume
```

### 3. API Service Upload
```
[APIService] uploadResume() called
[APIService] File URL: file:///path/to/SampleResume.pdf
[APIService] File name: SampleResume.pdf
[APIService] File exists, reading data...
[APIService] File data read successfully, size: [size] bytes
[APIService] Detecting MIME type for: SampleResume.pdf
[APIService] Extension-based MIME type: application/pdf
[APIService] Using MIME type for upload: application/pdf
[APIService] Sending POST request to: https://jobmatchnow.ai/api/resume
[APIService] Request Content-Type: multipart/form-data; boundary=[UUID]
[APIService] File Content-Type in multipart: application/pdf
```

### 4. Success Response
```
[APIService] Response status code: 200
[APIService] Response body: {"view_token":"[token_value]"}
[APIService] Successfully decoded response
[APIService] Received view_token: [token_value]
[UploadResumeView] Upload success! Received viewToken: [token_value]
[UploadResumeView] Navigating to PipelineLoadingView with viewToken=[token_value]
```

### 5. Pipeline Loading
```
DEBUG: Starting session status polling with viewToken: [token_value]
DEBUG: Polling session status...
DEBUG: Checking session status at: https://jobmatchnow.ai/api/public/session?token=[token_value]
DEBUG: Session status response - Status code: 200
DEBUG: Session status decoded - status: running/completed
DEBUG: Status completed, fetching jobs
DEBUG: Fetching jobs from: https://jobmatchnow.ai/api/public/jobs?token=[token_value]
DEBUG: Fetched [N] jobs
DEBUG: Jobs stored, scheduling navigation
DEBUG: Setting navigateToResults = true
```

## What to Verify

1. ✅ **No INVALID_FILE_TYPE error** - The upload should succeed with status 200
2. ✅ **Correct MIME type** - Should show `application/pdf`, NOT `application/octet-stream`
3. ✅ **View token received** - A valid view_token should be returned
4. ✅ **Pipeline starts** - App should navigate to PipelineLoadingView
5. ✅ **Polling works** - Should see status checks every 2 seconds
6. ✅ **Jobs fetched** - Should eventually fetch and display job results

## Troubleshooting

### If you see INVALID_FILE_TYPE error:
- Check that MIME type shows as `application/pdf` not `application/octet-stream`
- Verify the multipart Content-Type header includes correct MIME

### If upload fails with network error:
- Verify device has internet connection
- Check that backend is running at https://jobmatchnow.ai

### If SampleResume.pdf not found:
- Make sure SampleResume.pdf is added to Xcode target
- Check "Copy Bundle Resources" build phase includes the file

## Important Notes

- The debug button bypasses the flaky file picker entirely
- Uses a bundled PDF file from app resources
- Shares the exact same upload logic as the file picker path
- All MIME type detection improvements apply to both paths