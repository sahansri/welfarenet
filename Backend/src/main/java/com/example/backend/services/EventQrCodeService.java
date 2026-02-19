package com.example.backend.services;

import com.example.backend.entity.Event;
import com.example.backend.entity.EventQrCode;
import com.example.backend.repository.EventQrCodeRepository;
import com.google.zxing.BarcodeFormat;
import com.google.zxing.MultiFormatWriter;
import com.google.zxing.WriterException;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.common.BitMatrix;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class EventQrCodeService {

    private final EventQrCodeRepository qrRepo;
    private final S3Service s3Service;

    public EventQrCode generateQRCode(Event event) throws Exception {
        String qrContent = "EVENT_ID=" + event.getEventId();
        byte[] qrImage = generateQrImage(qrContent);

        String key = "qr/event_" + event.getEventId() + ".png";
        String qrUrl = s3Service.uploadBytes(qrImage, key, "image/png");

        EventQrCode qr = new EventQrCode();
        qr.setEvent(event);
        qr.setQrCodeUrl(qrUrl);
        qr.setQrCodeData(qrContent);
        qr.setGeneratedTime(LocalDateTime.now());
        qr.setExpiredTime(LocalDateTime.now().plusHours(1));
        qr.setExpired(false);

        return qrRepo.save(qr);
    }

    public EventQrCode getQRCodeForEvent(Integer eventId) {
        return qrRepo.findByEvent_EventId(eventId)
                .orElseThrow(() -> new RuntimeException("QR Code not found"));
    }

    public Integer validateQrAndGetEventId(String qrContent) {
        // Example QR format: "EVENT:12"
        if (!qrContent.startsWith("EVENT:")) {
            return null;
        }

        Pattern p = Pattern.compile("\\d+");
        Matcher m = p.matcher(qrContent);
        if (!m.find()) {
            return null;
        }
        try {
            return Integer.valueOf(m.group());
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    private byte[] generateQrImage(String content) throws Exception {
        try {
            BitMatrix matrix = new MultiFormatWriter()
                    .encode(content, BarcodeFormat.QR_CODE, 300, 300);

            ByteArrayOutputStream out = new ByteArrayOutputStream();
            MatrixToImageWriter.writeToStream(matrix, "PNG", out);

            return out.toByteArray();
        }catch (WriterException | IOException e) {
            throw new RuntimeException("Failed to generate QR image", e);
        }
    }
}


