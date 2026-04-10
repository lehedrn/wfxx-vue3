-- 模拟数据：设备型号管理（5 条）
INSERT INTO base_device_model (name, device_type, memory, disk, os, motherboard_manufacturer, cpu_model, cpu_cores, cpu_frequency, cpu_count, gpu_model, gpu_compute_power, gpu_memory, gpu_count, status, remark) VALUES
('EdgeBox-A100', '0', 8, 256, '0', 'Rockchip', 'RK3588', 8, 2.40, 1, NULL, NULL, NULL, 0, '0', '边缘计算盒子-入门款'),
('EdgeBox-A200', '0', 16, 512, '0', 'Rockchip', 'RK3588', 8, 2.40, 1, 'jetson_nano_jepck4.6', '21 TOPS', 4, 1, '0', '边缘计算盒子-标准款'),
('Server-S800', '1', 64, 2048, '0', 'Intel', 'Intel Xeon E5-2665', 8, 2.40, 2, 'NVIDIA RTX-3090Ti', '40 TFLOPS', 24, 2, '0', '高性能服务器-AI训练'),
('Server-S600', '1', 32, 1024, '1', 'Dell', 'Intel Xeon E5-2665', 8, 2.40, 1, 'NVIDIA RTX-3090Ti', '40 TFLOPS', 24, 1, '0', '服务器-Win平台'),
('EdgeBox-A300', '0', 16, 128, '0', 'Rockchip', 'RK3588', 8, 2.40, 1, NULL, NULL, NULL, 0, '1', '边缘计算盒子-测试环境');
