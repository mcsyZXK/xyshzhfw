package com.controller;

import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.util.Date;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.IOUtils;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.annotation.IgnoreAuth;
import com.baomidou.mybatisplus.mapper.EntityWrapper;
import com.entity.ConfigEntity;
import com.entity.EIException;
import com.service.ConfigService;
import com.utils.R;

/**
 * 上传文件映射表
 */
@RestController
@RequestMapping("file")
@SuppressWarnings({"unchecked","rawtypes"})
public class FileController{
	@Autowired
    private ConfigService configService;

	@Value("${upload.path:upload/}")
	private String uploadPath;

	private File getUploadDirectory() {
		File uploadDir = Paths.get(uploadPath).toAbsolutePath().normalize().toFile();
		if (!uploadDir.exists()) {
			uploadDir.mkdirs();
		}
		return uploadDir;
	}
	/**
	 * 上传文件
	 */
	@RequestMapping("/upload")
	public R upload(@RequestParam("file") MultipartFile file, String type,HttpServletRequest request) throws Exception {
		if (file.isEmpty()) {
			throw new EIException("上传文件不能为空");
		}
		String originalFilename = file.getOriginalFilename();
		String fileExt = "";
		if (StringUtils.isNotBlank(originalFilename) && originalFilename.contains(".")) {
			fileExt = originalFilename.substring(originalFilename.lastIndexOf(".") + 1);
		}
		String fileName = StringUtils.isNotBlank(fileExt) ? new Date().getTime()+"."+fileExt : String.valueOf(new Date().getTime());
		File dest = new File(getUploadDirectory(), fileName);
		file.transferTo(dest);
		if(StringUtils.isNotBlank(type) && type.equals("1")) {
			ConfigEntity configEntity = configService.selectOne(new EntityWrapper<ConfigEntity>().eq("name", "faceFile"));
			if(configEntity==null) {
				configEntity = new ConfigEntity();
				configEntity.setName("faceFile");
				configEntity.setValue(fileName);
			} else {
				configEntity.setValue(fileName);
			}
			configService.insertOrUpdate(configEntity);
		}
		return R.ok().put("file", fileName);
	}
	
	/**
	 * 下载文件
	 */
	@IgnoreAuth
	@RequestMapping("/download")
	public void download(@RequestParam String fileName, HttpServletRequest request, HttpServletResponse response) {
		try {
			File file = new File(getUploadDirectory(), fileName);
			if (file.exists()) {
				response.reset();
				response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName+"\"");
				response.setHeader("Cache-Control", "no-cache");
				response.setHeader("Access-Control-Allow-Credentials", "true");
				response.setContentType("application/octet-stream; charset=UTF-8");
				IOUtils.write(FileUtils.readFileToByteArray(file), response.getOutputStream());
			}

		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	
}
