# Debug Button Test Checklist

## Enhanced Error Logging (Updated)

The resume upload function now includes comprehensive error logging and diagnosis to help identify timeout and connection issues.

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

### 3. API Service Upload (Enhanced Logging)
```
========================================
[APIService] RESUME UPLOAD START
========================================
[APIService] File URL: file:///path/to/SampleResume.pdf
[APIService] File name: SampleResume.pdf
[APIService] Timestamp: 2025-11-21 10:30:00
[APIService] File exists, reading data...
[APIService] File data read successfully, size: [size] bytes
[APIService] Detecting MIME type for: SampleResume.pdf
[APIService] Extension-based MIME type: application/pdf
[APIService] Using MIME type for upload: application/pdf
[APIService] ----------------------------------------
[APIService] REQUEST DETAILS:
[APIService] URL: https://jobmatchnow.ai/api/resume
[APIService] Method: POST
[APIService] Content-Type: multipart/form-data; boundary=[UUID]
[APIService] Body size: [size] bytes
[APIService] File MIME type in multipart: application/pdf
[APIService] Timeout interval: 30.0 seconds
[APIService] ----------------------------------------
[APIService] Sending request at: 2025-11-21 10:30:00
```

### 4. Success Response (Enhanced)
```
[APIService] Request completed in: 1.25 seconds
[APIService] ========================================
[APIService] RESPONSE RECEIVED
[APIService] HTTP Status Code: 200
[APIService] HTTP Status: no error
[APIService] Response Headers:
[APIService]   Content-Type: application/json
[APIService]   Content-Length: 45
[APIService] Response Body Size: 45 bytes
[APIService] Response Body (as string):
[APIService] {"view_token":"abc123def456"}
[APIService] ========================================
[APIService] SUCCESS: Response decoded successfully
[APIService] Received view_token: abc123def456
[APIService] ========================================
[APIService] RESUME UPLOAD SUCCESS
[APIService] ========================================
[UploadResumeView] Upload success! Received viewToken: abc123def456
[UploadResumeView] Navigating to PipelineLoadingView with viewToken=abc123def456
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

## Error Scenarios (New Enhanced Logging)

### Timeout Error Example:
```
[APIService] Sending request at: 2025-11-21 10:30:00
[APIService] ========================================
[APIService] NETWORK ERROR after 30.00 seconds
[APIService] URLError Code: -1001
[APIService] Error Description: The request timed out.
[APIService] ERROR TYPE: Request Timeout
[APIService] The server did not respond within the timeout interval
[APIService] ========================================
[UploadResumeView] APIError caught: networkError(URLError(_nsError: Error Domain=NSURLErrorDomain Code=-1001))
[UploadResumeView] Showing error alert: Upload failed: Request timed out. Please check your internet connection and try again.
```

### DNS/Connection Error Example:
```
[APIService] ========================================
[APIService] NETWORK ERROR after 5.32 seconds
[APIService] URLError Code: -1003
[APIService] Error Description: A server with the specified hostname could not be found.
[APIService] ERROR TYPE: DNS Failure
[APIService] Cannot resolve host: https://jobmatchnow.ai
[APIService] ========================================
[UploadResumeView] Showing error alert: Upload failed: Cannot connect to server (DNS error)
```

### HTTP Error Example:
```
[APIService] ========================================
[APIService] RESPONSE RECEIVED
[APIService] HTTP Status Code: 400
[APIService] HTTP Status: bad request
[APIService] Response Headers:
[APIService]   Content-Type: text/plain
[APIService] Response Body (as string):
[APIService] INVALID_FILE_TYPE
[APIService] ========================================
[APIService] ERROR: HTTP Error
[APIService] Status Code: 400
[APIService] Error Message: INVALID_FILE_TYPE
[UploadResumeView] Showing error alert: Invalid file format: INVALID_FILE_TYPE
```

## Troubleshooting

### If you see a timeout error:
- Check that the backend server is running and accessible
- Verify network connectivity
- Consider if file size is too large (check Body size in logs)
- The default timeout is 30 seconds

### If you see INVALID_FILE_TYPE error:
- Check that MIME type shows as `application/pdf` not `application/octet-stream`
- Verify the multipart Content-Type header includes correct MIME

### If upload fails with network error:
- Check the specific URLError code in logs
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