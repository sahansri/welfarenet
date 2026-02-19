# S3 Image Access Solution - Complete Guide

## Problem Summary
You were unable to access images stored in AWS S3 bucket through your NewsFeed API because:
1. S3 bucket wasn't configured for public access
2. AWS credentials weren't properly configured for presigned URLs
3. Hibernate MultipleBagFetchException when fetching both images and comments

## Solutions Implemented

### 1. Fixed AWS Credentials Configuration

**File: `S3Config.java`**
- Added `S3Presigner` bean with proper AWS credentials
- Both `S3Client` and `S3Presigner` now use `StaticCredentialsProvider` with your AWS credentials

```java
@Bean
public S3Presigner s3Presigner() {
    AwsBasicCredentials creds = AwsBasicCredentials.create(accessKey, secretKey);
    return S3Presigner.builder()
            .region(Region.of(region))
            .credentialsProvider(StaticCredentialsProvider.create(creds))
            .build();
}
```

### 2. Fixed Hibernate MultipleBagFetchException

**File: `NewsFeedRepository.java`**
- Split the query into two separate queries to avoid fetching multiple bags simultaneously
- `findAllWithImagesAndAuthors()` - fetches posts with images and authors
- `fetchComments()` - fetches comments separately

```java
@Query("select distinct nf from NewsFeed nf " +
        "left join fetch nf.author a " +
        "left join fetch nf.images i " +
        "order by nf.datePosted desc, nf.timePosted desc")
List<NewsFeed> findAllWithImagesAndAuthors();

@Query("select distinct nf from NewsFeed nf " +
        "left join fetch nf.comments c " +
        "left join fetch c.member m " +
        "where nf in :posts")
List<NewsFeed> fetchComments(@Param("posts") List<NewsFeed> posts);
```

### 3. Implemented Presigned URL Generation

**File: `NewsFeedService.java`**
- Updated `getAllPostsWithCommentsAndAuthors()` to generate presigned URLs
- Presigned URLs are valid for 1 hour
- Added error handling for URL generation

```java
@Transactional(readOnly = true)
public List<NewsFeed> getAllPostsWithCommentsAndAuthors() {
    // First fetch posts with images and authors
    List<NewsFeed> posts = newsFeedRepository.findAllWithImagesAndAuthors();
    
    // Then fetch comments separately
    if (!posts.isEmpty()) {
        newsFeedRepository.fetchComments(posts);
    }

    // Generate presigned URLs for images
    for (NewsFeed post : posts) {
        if (post.getImages() != null && !post.getImages().isEmpty()) {
            for (NewsFeedImage image : post.getImages()) {
                try {
                    String key = extractKeyFromUrl(image.getImagePath());
                    String presignedUrl = presignerService.presignGetUrl(key, Duration.ofHours(1));
                    image.setImagePath(presignedUrl);
                } catch (Exception e) {
                    System.err.println("Failed to generate presigned URL for: " + image.getImagePath());
                    e.printStackTrace();
                }
            }
        }
    }

    return posts;
}
```

### 4. Updated S3Service

**File: `S3Service.java`**
- Changed upload folder from "uploads" to "newsfeed" for consistency
- Files are now uploaded to: `newsfeed/{UUID}-{filename}`

## How It Works

### Image Upload Flow:
1. Client uploads image via `/api/newsfeed/create` endpoint
2. `S3Service.uploadFile()` uploads to S3 bucket under `newsfeed/` folder
3. Returns S3 URL: `https://welfarenet.s3.ap-southeast-1.amazonaws.com/newsfeed/{UUID}-{filename}`
4. URL is stored in database

### Image Retrieval Flow:
1. Client calls `/api/newsfeed/sorted-bydate` endpoint
2. `NewsFeedService.getAllPostsWithCommentsAndAuthors()` fetches posts from database
3. For each image, extracts the S3 key from the URL
4. Generates presigned URL valid for 1 hour using `S3PresignerService`
5. Returns posts with presigned URLs

### Presigned URLs:
- **Benefit**: No need to make S3 bucket public
- **Security**: Temporary access (1 hour)
- **Format**: `https://welfarenet.s3.ap-southeast-1.amazonaws.com/newsfeed/{UUID}-{filename}?X-Amz-Algorithm=...&X-Amz-Credential=...&X-Amz-Signature=...`

## API Endpoints

### Create Post with Images (multipart/form-data)
```
POST /api/newsfeed/create
Content-Type: multipart/form-data

Parameters:
- authorId: Integer (required)
- content: String (optional)
- images: List<MultipartFile> (optional)
```

**Postman Configuration:**
- Body → form-data
- authorId: Text field with value (e.g., "1")
- content: Text field with your content
- images: File field (select image files)

### Get All Posts with Images
```
GET /api/newsfeed/sorted-bydate
```

**Response Example:**
```json
[
  {
    "postID": 29,
    "author": {
      "memberID": 2,
      "fullName": "Tissera",
      "totalStars": 0
    },
    "content": "sample",
    "images": [
      {
        "imgId": 12,
        "imagePath": "https://welfarenet.s3.ap-southeast-1.amazonaws.com/newsfeed/25f3a62a-9c39-4ead-af36-947c05066c4c-20220808_095138.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&..."
      }
    ],
    "datePosted": "2026-01-02",
    "timePosted": "16:13:22.58",
    "likes": [],
    "comments": [],
    "likeCount": 0,
    "commentCount": 0
  }
]
```

## Testing

### Test Image Access:
1. Start the application: `./mvnw spring-boot:run`
2. Call the API: `GET http://localhost:8080/api/newsfeed/sorted-bydate`
3. Copy an image URL from the response (presigned URL)
4. Paste it in your browser - the image should display
5. The presigned URL will expire after 1 hour

### Upload New Image:
1. Use Postman or similar tool
2. POST to: `http://localhost:8080/api/newsfeed/create`
3. Body type: form-data
4. Add fields:
   - `authorId` (Text): "1"
   - `content` (Text): "Your post content"
   - `images` (File): Select image file(s)
5. Send request

## Configuration

Your `application.properties` has the correct AWS configuration:
```properties
aws.region=ap-southeast-1
aws.s3.bucket=welfarenet
aws.accessKeyId=AKIAWVDH6BB4JM36PN2Y
aws.secretAccessKey=+LMqV+iBWEFEjp4SFXCUkTeO7/b40gdJKs25UXTL
```

⚠️ **Security Note**: Never commit AWS credentials to version control. Consider using:
- Environment variables in production
- AWS Secrets Manager
- IAM roles (if running on EC2)

## Troubleshooting

### If images still don't load:
1. **Check AWS credentials**: Verify they're correct in `application.properties`
2. **Check S3 bucket exists**: Bucket name is "welfarenet"
3. **Check S3 region**: Should be "ap-southeast-1"
4. **Check IAM permissions**: Your AWS user needs:
   - `s3:PutObject`
   - `s3:GetObject`
5. **Check presigned URL**: Should contain query parameters starting with `?X-Amz-`

### If MultipleBagFetchException occurs:
- This has been fixed by splitting queries
- If it still occurs, one collection might need to be a `Set` instead of `List`

### If application fails to start:
- Port 8080 might be in use: Kill Java processes or change port
- Database connection: Check MySQL credentials and connection

## Next Steps

1. **Test the solution**: Start the app and test the GET endpoint
2. **Upload a new image**: Test the POST endpoint with Postman
3. **Verify image access**: Click the presigned URL in the response
4. **Monitor expiration**: Presigned URLs expire after 1 hour

## Alternative Solution: Public Bucket

If you want to avoid presigned URLs and make images permanently accessible:

1. **Update S3 Bucket Policy**:
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::welfarenet/newsfeed/*"
        }
    ]
}
```

2. **Disable Block Public Access** in S3 bucket settings

3. **Remove presigned URL generation** from `NewsFeedService`

⚠️ **Not recommended** for security reasons - use presigned URLs instead.

