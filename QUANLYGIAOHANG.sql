-- Xóa cơ sở dữ liệu nếu đã tồn tại
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'QUANLYGIAOHANG')
BEGIN
    USE master; -- Chuyển sang cơ sở dữ liệu master để có thể xóa được cơ sở dữ liệu khác
    ALTER DATABASE QUANLYGIAOHANG SET SINGLE_USER WITH ROLLBACK IMMEDIATE; -- Ngắt mọi kết nối
    DROP DATABASE QUANLYGIAOHANG; -- Xóa cơ sở dữ liệu
END
-- Lệnh tạo database QUANLYGIAOHANG
create database QUANLYGIAOHANG
go
-- Sử dụng database QUANLYGIAOHANG
use QUANLYGIAOHANG
-- Tạo table Khách hàng
create table KHACHHANG
(
	makhachhang char(5) primary key,
	tencongty nvarchar(100),
	tengiaodich nvarchar(50),
	diachi nvarchar(100) not null,
	email varchar(50) unique
		check(email like '[a-z]%@%_'),
	dienthoai varchar(11) unique not null
		check(dienthoai like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
			or dienthoai like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
	fax varchar(11) unique
)
-- Tạo table Nhân Viên
create table NHANVIEN
(
	manhanvien char(5) primary key,
	ho nvarchar(10),
	ten nvarchar(10) not null,
	ngaysinh date,
	ngaylamviec date,
	diachi nvarchar(100) not null,
	dienthoai varchar(11) unique not null
		check(dienthoai like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
			or dienthoai like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
	luongcoban decimal(18,0) check(luongcoban > 0),
	phucap decimal (18,0) check (phucap > 0 )
)
-- Tạo table Đơn đặt hàng
create table DONDATHANG
(
	sohoadon char(5) primary key,
	makhachhang char(5),
	manhanvien char(5),
	ngaydathang date not null
		check (ngaydathang <= getdate()),
	ngaygiaohang date,
	ngaychuyenhang date,
	noigiaohang nvarchar(100) not null,
	foreign key(makhachhang) references KHACHHANG(makhachhang)
		on update 
			cascade
		on delete 
			cascade,
	foreign key(manhanvien) references NHANVIEN(manhanvien)
		on update 
			cascade
		on delete 
			cascade
)
-- Tạo table Nhà cung cấp
create table NHACUNGCAP
(
	macongty char(5) primary key,
	tencongty nvarchar(100),
	tengiaodich nvarchar(100),
	diachi nvarchar(100) not null,
	dienthoai varchar(11) unique not null
		check(dienthoai like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
			or dienthoai like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
	fax varchar(11) unique,
	email varchar(50) unique not null
		check(email like '[a-z]%@%_'),
)
-- Tạo table Loại hàng
create table LOAIHANG
(
	maloaihang char(5) primary key,
	tenloaihang nvarchar(100),
)
-- Tạo table Mặt hàng
create table MATHANG
(
	mahang char(5) primary key,
	tenhang nvarchar(100),
	macongty char(5),
	maloaihang char(5),
	soluong int check(soluong >= 0),
	donvitinh nvarchar(50) not null,
	giahang decimal(18,0) not null check(giahang >=0 ),
    foreign key (maloaihang) references LOAIHANG(maloaihang)
		on update 
			cascade
		on delete 
			cascade,
    foreign key (macongty) references NHACUNGCAP(macongty)
		on update 
			cascade
		on delete 
			cascade
)
-- Tạo table Chi tiết đơn hàng
create table CHITIETDONHANG
(
	sohoadon char(5),
	mahang char(5),
	giaban decimal(18,0) not null check (giaban >= 0),
	soluong int check(soluong > 0),
	mucgiamgia decimal(5,2), 
	primary key(sohoadon,mahang),
	foreign key (sohoadon) references DONDATHANG(sohoadon)
		on update 
			cascade
		on delete 
			cascade,
	foreign key (mahang) references MATHANG(mahang)
		on update 
			cascade
		on delete 
			cascade
)
go
-- Thay đổi cấu trúc bảng Chi tiết đơn đặt hàng
alter table CHITIETDONHANG
	add constraint DF_ChiTietDonHang_Soluong
			default 1 for soluong,
		constraint DF_ChiTietDonHang_MucGiamGia
			default 0 for mucgiamgia
-- Thay đổi cấu trúc bảng Đơn đặt hàng
alter table DONDATHANG
	add constraint CK_DonDatHang_ngayGiaoHang
			check(ngaygiaohang >= ngaydathang),
		constraint CK_DonDatHang_ngayChuyenHang
			check(ngaychuyenhang >= ngaydathang)
-- Thay đổi cấu trúc bảng Nhân viên
alter table NHANVIEN
	add constraint CK_NhanVien_ngayLamViec
			check (ngaylamviec >= dateadd(year,18,ngaysinh) 
				AND ngaylamviec <= dateadd(year,60,ngaysinh)),
		constraint CK_NhanVien_ngaySinh
			check (ngaysinh < getdate())
insert into KHACHHANG
values  ('KH001',N'Công ty xây dựng nhà ở',N'Nguyễn Văn A',N'59 Diên Hồng, Hòa Xuân, Cẩm Lệ, Đà Nẵng','huynee@gmail.com','0223333223','7255756766'),
	    ('KH002',N'Công ty bất động sản',N'Nguyễn Văn B',N'59 Hùng Vương, Thanh Hà, Hội An, Quảng Nam','hdongsan@gmail.com','0223442239','5544545444'),
	    ('KH003',N'Công ty TNHH xi măng',N'Nguyễn Văn C',N'12, Lê Thánh Tông, Tràng Tiền, Hoàn Kiếm, Hà Nội','ximanwgn@gmail.com','0553482239','9876543211'),
	    ('KH004',N'Công ty sản xuất bánh kẹo',N'Nguyễn Văn D',N'89 Trần Phú, Hải Châu 1, Hải Châu, Đà Nẵng','banhkeo@gmail.com','0553742239','1234567899'),
	    ('KH005',N'Công ty sản xuất bánh mì',N'Nguyễn Văn E',N'35 Lạch Tray, Cầu Đất, Ngô Quyền, Hải Phòng','banhmi@gmail.com','0553443239','1587567899'),
	    ('KH006',N'Công ty sản xuất dầu gội',N'Nguyễn Văn F',N'55 Mai Am, Bình Trị Đông B, Bình Tân, TP Hồ Chí Minh','daugoi@gmail.com','0557742239','1554567899'),
	    ('KH007',N'Công ty cầu đường',N'Nguyễn Văn G',N'678 Trần Phú, Thành phố Huế, Thừa Thiên Huế','cauduong@gmail.com','0559842239','1554604699'),
	    ('KH008',N'Công ty sản xuất bàn phím',N'Nguyễn Văn H',N'123 Nguyễn Huệ, Quận 1, TP Hồ Chí Minh','banphim@gmail.com','0598442239','1554560299'),
	    ('KH009',N'Công ty sản xuất nước ngọt',N'Nguyễn Văn J',N'15 Đường 3/2, Thành phố Nha Trang, Khánh Hòa','nuocngot@gmail.com','0553782239','1554534899'),
	    ('KH010',N'Công ty sản xuất cốc nước',N'Nguyễn Văn K',N'45 Lê Duẩn, Quận Hải Châu, Đà Nẵng','cocnuoc@gmail.com','0775367239','1554565499')
set dateformat dmy
insert into NHANVIEN
values  ('NV001', N'Nguyễn',N'An','15-1-1980','20-10-2005',N'12 Lê Thánh Tông, Tràng Tiền, Hoàn Kiếm, Hà Nội','0912345678',5000000,1000000),
		('NV002', N'Trần',N'Bình','20-3-1999','5-5-2019',N'45 Quang Trung, 7, Gò Vấp, TP Hồ Chí Minh','0987654321',6000000,1200000),
		('NV003', N'Phạm',N'Cường','10-3-2000','6-7-2021',N'89 Trần Phú, Hải Châu 1, Hải Châu, Đà Nẵng','0901234567',5500000,1100000),
		('NV004', N'Lê',N'Duy','25-4-1998','10-12-2023',N'35 Lạch Tray, Cầu Đất, Ngô Quyền, Hải Phòng','0934567890',5200000,900000),
		('NV005', N'Nguyễn',N'Lan','15-5-1999','25-1-2022',N'22 Tô Hiệu, Nguyễn Trãi, Hà Đông, Hà Nội','0945678901',5300000,950000),
		('NV006', N'Trần',N'Nam','5-5-2003','1-7-2024',N'120 Cộng Hòa, 15, Tân Bình, TP Hồ Chí Minh','0923456789',6100000,1500000),
		('NV007', N'Phạm',N'Phúc','10-3-2000','25-11-2023',N'76 Bạch Đằng, Thạch Thang, Hải Châu, Đà Nẵng','0910987654',5400000,1000000),
		('NV008', N'Lê',N'Quỳnh','20-5-1999','5-4-2022',N'234 Cầu Giấy, Quan Hoa, Cầu Giấy, Hà Nội','0981123456',5600000,980000),
		('NV009', N'Nguyễn',N'Sơn','10-10-1965','15-10-1983',N'55 Tên Lửa, Bình Trị Đông B, Bình Tân, TP Hồ Chí Minh','0909988776',5700000,1100000),
		('NV010', N'Trần',N'Tuấn','24-10-2005','30-9-2024',N'789 Kim Mã, Ngọc Khánh, Ba Đình, Hà Nội','0912233445',5800000,1150000)
set dateformat dmy
insert into DONDATHANG
values	('HD001','KH001','NV001','10-01-2024','15-01-2024','12-01-2024',N'Số 10 Trần Hưng Đạo, Phường Cô Giang, Quận 1, TP Hồ Chí Minh'),
		('HD002','KH002','NV002','01-02-2024','05-02-2024','02-02-2024',N'Số 12 Đường Đê La Thành, Đống Đa, Hà Nội'),
		('HD003','KH003','NV005','15-02-2024','20-02-2024','18-02-2024',N'Số 45 Lê Văn Khương, Phường Thới An, Quận 12, TP Hồ Chí Minh'),
		('HD004','KH002','NV002','25-01-2024','30-01-2024','28-01-2024',N'Số 20 Nguyễn Văn Cừ, Phường 3, Quận 5, TP Hồ Chí Minh'),
		('HD005','KH002','NV006','05-03-2024','10-03-2024','07-03-2024',N'Số 78 Ngọc Khánh, Ba Đình, Hà Nội'),
		('HD006','KH003','NV008','30-01-2024','04-02-2024','01-02-2024',N'Số 101 Lê Lai, Phường Bến Thành, Quận 1, TP Hồ Chí Minh'),
		('HD007','KH004','NV003','10-02-2006','15-02-2024','12-02-2024',N'Số 3 Nguyễn Hữu Cảnh, Bình Thạnh, TP Hồ Chí Minh'),
		('HD008','KH003','NV001','01-03-2024','05-03-2024','02-03-2024',N'Số 57 Lê Thị Riêng, Quận 1, TP Hồ Chí Minh'),
		('HD009','KH010','NV008','20-02-2008','25-02-2024','22-02-2024',N'Số 88 Đinh Tiên Hoàng, Bình Thạnh, TP Hồ Chí Minh'),
		('HD010','KH010','NV010','15-01-2024','20-01-2024','18-01-2024',N'Số 45 Phố Huế, Hai Bà Trưng, Hà Nội')
insert into LOAIHANG 
values	('LH001',N'Điện tử'),
		('LH002',N'Nội thất'),
		('LH003',N'Thời trang'),
		('LH004',N'Thực phẩm'),
		('LH005',N'Mỹ phẩm'),
		('LH006',N'Thể thao'),
		('LH007',N'Xây dựng'),
		('LH008',N'Học tập'),
		('LH009',N'Đồ chơi'),
		('LH010',N'Phụ kiện')
insert into NHACUNGCAP
values	('CC001',N'Công ty xây dựng', N'Nguyễn Văn A',N'123 Nguyễn Trãi, Quận 1, TP. Hồ Chí Minh','0912345678', '0241234567', 'xaydung@gmail.com'),
		('CC002',N'Công ty Thực phẩm',N'Nguyễn Thị B',N'456 Lê Lợi, Quận Hải Châu, TP. Đà Nẵng','0987654321', '0287654321', 'noithat@gmail.com'),
		('CC003',N'Công ty thời trang',N'Nguyễ Văn C',N'789 Hai Bà Trưng, Quận Hoàn Kiếm, TP. Hà Nội','0901234567', '0236123456', 'thoitrang@gmail.com'),
		('CC004',N'Công ty Đầu tư và Phát triển thể thao',N'Nguyễn Bảo Trung',N'101 Trần Hưng Đạo, Quận Ninh Kiều, TP. Cần Thơ','0934567890','0312345678','thethaoi@gmail.com'),
		('CC005',N'Công ty Cổ phần Sản xuất nội thất đồ chơi',N'Trần Minh Chiến',N'202 Phạm Văn Đồng, Quận Liên Chiểu, TP. Đà Nẵng','0945678901','0247654321','dochoi@gmail.com'),
		('CC006',N'Công ty Cổ phần Công nghệ Điện tử',N'Nguyễn Thị D',N'303 Võ Văn Tần, Quận 3, TP. Hồ Chí Minh','0923456789','0288765432', 'dientu@gmail.com'),
		('CC007',N'Công ty Việt Tiến',N'Nguyễn Văn C',N'404 Điện Biên Phủ, Quận Bình Thạnh, TP. Hồ Chí Minh', '0910987654','0236654321','hoctap@gmail.com'),
		('CC008',N'Công ty cổ phần Sản xuất mỹ phẩm',N'Lê B',N'505 Cộng Hòa, Quận Tân Bình, TP. Hồ Chí Minh','0981123456','0249988776','mypham@gmail.com'),
		('CC009',N'Công ty Thương mại Quốc tế',N'Lê Văn A',N'606 Trường Chinh, Quận Thanh Xuân, TP. Hà Nội','0909988776','0289988776','quocte@gmail.com'),
		('CC010',N'Công ty Sản suất đồ ăn',N'Vinamilk',N'707 Phạm Hùng, Huyện Bình Chánh, TP. Hồ Chí Minh','0912233445','0242233445','batdongsan@gmail.com')
insert into MATHANG
values	('MH001',N'Tivi','CC006','LH001',5,N'Cái',3000000),
		('MH002',N'Tủ lạnh','CC002','LH004', 30,N'Cái',8000000),
		('MH003',N'Điện thoại di động','CC006','LH001',100,N'Cái',1500000),
		('MH004',N'Sữa hộp','CC010','LH004', 20,N'Hộp',4500000),
		('MH005',N'Ghế sofa','CC002','LH002', 15,N'Bộ',12000000),
		('MH006',N'Bàn làm việc','CC007','LH008',25,N'Chiếc',2500000),
		('MH007',N'Xi măng','CC001','LH007',0,N'Bao',3000000),
		('MH008',N'Giày thể thao','CC004','LH006',60,N'Đôi',800000),
		('MH009',N'Sách học','CC007','LH008',0,N'Cuốn',150000),
		('MH010',N'Nước hoa','CC008','LH005',100,N'Lọ',500000)
insert into CHITIETDONHANG
values	('HD001','MH001',2800000,2,0.1),
		('HD001','MH002',7800000,1,0.00),
		('HD002','MH004',1450000,3,0.15),
		('HD002','MH002',4200000,4,0.20),
		('HD003','MH004',11500000,2,0.00),
		('HD003','MH006',2400000,4,0.6),
		('HD004','MH003',2900000,5,0.5),
		('HD004','MH002',750000,3,0.2),
		('HD005','MH008',130000,10,0.3),
		('HD005','MH006',480000,5,0.03)
--1. Tăng phụ cấp lên bằng 50% lương cho những nhân viên bán được hàng nhiều nhất
select * from NHANVIEN
update NHANVIEN
set phucap = luongcoban*0.5
where manhanvien in (select manhanvien
					 FROM DONDATHANG dh, CHITIETDONHANG ct
					 where dh.sohoadon = ct.sohoadon
					 group by manhanvien
					 having SUM(soluong) >= all
						(select SUM(soluong)
						 from DONDATHANG dh, CHITIETDONHANG ct
						 where dh.sohoadon = ct.sohoadon
						 group by manhanvien))
select * from NHANVIEN
/*update NHANVIEN
set phucap = 0.5 * luongcoban
where manhanvien IN (select manhanvien from DONDATHANG 
	group by manhanvien
    having COUNT(sohoadon) = (select MAX(tongsohoadon)
        from (select COUNT(sohoadon) tongsohoadon from DONDATHANG group by manhanvien) subquery))*/
--select * from NHANVIEN
--2. Giảm 25% lương của những nhân viên trong năm 2023 không lập được bất kỳ đơn đặt hàng nào.
update NHANVIEN
set luongcoban = luongcoban * 0.75
where manhanvien not in (
    select manhanvien
    from DONDATHANG
    where YEAR(ngaydathang) = 2023
)
	and YEAR(ngaylamviec) <= 2023
select * from NHANVIEN
--3. Xoá khỏi bảng NHANVIEN những nhân viên đã làm việc trong công ty quá 40 năm
delete NHANVIEN
where datediff(YEAR, ngaylamviec, GETDATE()) > 40
select * from NHANVIEN
--4. Xóa những đơn đặt hàng trước năm 2010 ra khỏi cơ sở dữ liệu
delete DONDATHANG
where YEAR(ngaydathang) < 2010
select * from DONDATHANG
--5. xóa khỏi bảng MATHANG những mặt hàng có số lượng bằng 0 và không được đặt mua trong bất kì đơn đặt hàng nào
delete MATHANG
where soluong = 0 and mahang not in(select mahang from CHITIETDONHANG)
select * from MATHANG

								------------SELECT-----------

--1.Cho biết danh sách các đối tác cung cấp hàng cho công ty
select * from NHACUNGCAP
--2.Mã hàng, tên hàng và số lượng của các mặt hàng hiện có trong công ty
select mahang, tenhang, soluong
from MATHANG
--3.Họ tên và địa chỉ và năm bắt đầu làm việc của các nhân viên trong công ty
select manhanvien,ho, ten, diachi, year(ngaylamviec) namBatDauLamViec
from NHANVIEN
--4.Địa chỉ và điện thoại của nhà cung cấp có tên giao dịch [VINAMILK]  là gì?
select macongty, tencongty, tengiaodich, diachi, dienthoai
from NHACUNGCAP
where tengiaodich = N'Vinamilk'
--5.Cho biết mã và tên của các mặt hàng có giá lớn hơn 100000 và số lượng hiện có ít hơn 50.
select mahang, tenhang, giahang, soluong
from MATHANG
where giahang > 100000 and soluong < 50
--6.Cho biết mỗi mặt hàng trong công ty do ai cung cấp
select mh.mahang, tenhang, ncc.tencongty
from NHACUNGCAP ncc, MATHANG mh
where ncc.macongty = mh.macongty
--7.Công ty [Việt Tiến] đã cung cấp những mặt hàng nào?
select mahang , tenhang
from NHACUNGCAP ncc, MATHANG mh
where ncc.macongty = mh.macongty and tencongty = N'Công ty Việt Tiến'
--8.Loại hàng thực phẩm do những công ty nào cung cấp và địa chỉ của các công ty đó là gì?
select lh.maloaihang,tenloaihang, tencongty, diachi
from MATHANG mh, NHACUNGCAP ncc, LOAIHANG lh
where mh.macongty = ncc.macongty and mh.maloaihang = lh.maloaihang and tenloaihang = N'Thực phẩm'
--9.Những khách hàng nào (tên giao dịch) đã đặt mua mặt hàng Sữa hộp XYZ của công ty?
select kh.makhachhang,tencongty,tengiaodich,tenhang
from DONDATHANG hd, KHACHHANG kh, MATHANG mh, CHITIETDONHANG ct
where hd.makhachhang = kh.makhachhang and ct.mahang = mh.mahang and hd.sohoadon = ct.sohoadon 
	and tenhang =N'Sữa hộp'
--10.Đơn đặt hàng số 1 do ai đặt và do nhân viên nào lập, thời gian và địa điểm giao hàng là ở đâu?
select sohoadon, kh.makhachhang, nv.manhanvien,ho,ten, ngaygiaohang, noigiaohang
from DONDATHANG dh, KHACHHANG kh, NHANVIEN nv
where dh.makhachhang = kh.makhachhang and nv.manhanvien = dh.manhanvien and sohoadon = N'HD001'
--11.Hãy cho biết số tiền lương mà công ty phải trả cho mỗi nhân viên là bao nhiêu (lương = lương cơ bản + phụ cấp).
select manhanvien, ho, ten, ngaysinh, ngaylamviec,luongcoban,phucap, sum(luongcoban + phucap) luong
from NHANVIEN
group by manhanvien, ho, ten, ngaysinh, ngaylamviec,luongcoban,phucap
--12.Hãy cho biết có những khách hàng nào lại chính là đối tác cung cấp hàng của công ty (tức là có cùng tên giao dịch).
select kh.makhachhang, kh.tengiaodich
from KHACHHANG kh, DONDATHANG dh, CHITIETDONHANG ct, MATHANG mh, NHACUNGCAP ncc
where kh.makhachhang = dh.makhachhang and dh.sohoadon = ct.sohoadon and ct.mahang = mh.mahang and mh.macongty = ncc.macongty
group by kh.makhachhang, kh.tengiaodich
--13.Trong công ty có những nhân viên nào có cùng ngày sinh?
--14.Những đơn đặt hàng nào yêu cầu giao hàng ngay tại công ty đặt hàng và những đơn đó là của công ty nào?


-------------- Hàm, thủ tục, trigger -----------------
--1)Tạo thủ tục lưu trữ để thông qua thủ tục này có thể bổ sung thêm một bản ghi mới cho bảng MATHANG 
--(thủ tục phải thực hiện kiểm tra tính hợp lệ của dữ liệu cần bổ sung: không trùng khoá chính và đảm bảo toàn vẹn tham chiếu)
go
create proc pr_boSungMatHang
    @mahang char(5),
    @tenhang nvarchar(100),
    @macongty char(5),
    @maloaihang char(5),
    @soluong int,
    @donvitinh nvarchar(50),
    @giahang decimal(18,0)
as
begin 
	-- Kiểm tra trùng khóa chính
    if exists(
        select 1
        from MATHANG
        where mahang = @mahang)
    begin
        RAISERROR ('Mã hàng đã tồn tại.', 16, 1)
        return
    end

	-- Kiểm tra tên hàng
	if exists(
		select 1
		from MATHANG
		where tenhang = @tenhang)
	begin
		RAISERROR ('Tên hàng đã tồn tại trong bảng',16,1)
		return
	end

    -- Kiểm tra tồn tại mã công ty trong bảng NHACUNGCAP
    if not exists (
        select 1
        from NHACUNGCAP
        where macongty = @macongty)
    begin
        RAISERROR ('Mã công ty không tồn tại.', 16, 1)
        return
    end

    -- Kiểm tra tồn tại mã loại hàng trong bảng LOAIHANG
    if not exists (
        select 1
        from LOAIHANG
        where maloaihang = @maloaihang)
    begin
        RAISERROR ('Mã loại hàng không tồn tại.', 16, 1)
        return
    end

    -- Thêm bản ghi mới vào bảng MATHANG
    insert into MATHANG (mahang, tenhang, macongty, maloaihang, soluong, donvitinh, giahang)
    values (@mahang, @tenhang, @macongty, @maloaihang, @soluong, @donvitinh, @giahang);
end
go
exec pr_boSungMatHang 'MH011', N'LapTop', 'CC006', 'LH008', '10', 'Cái', '1000000'
go
--2)Tạo thủ tục lưu trữ có chức năng thống kê tổng số lượng hàng bán được của một mặt hàng có mã bất kỳ 
--(mã mặt hàng cần thống kê là tham số của thủ tục). 

create proc pr_tongSoLuongHang
	@mahang char(5)
as
begin
	-- Kiểm tra tồn tại mã hàng
	if not exists(
        select 1
        from MATHANG
        where mahang = @mahang)
    begin
        RAISERROR ('Mã hàng không đã tồn tại trong bảng MATHANG.', 16, 1)
        return
    end

	-- Thống kê tổng số lượng hàng bán được
	  select @mahang MaHang,
           ISNULL((
               select SUM(soluong)
               from CHITIETDONHANG
               where mahang = @mahang), 0) 'Tổng số lượng bán'
end
go
exec pr_tongSoLuongHang 'MH010'
go
--3)Viết hàm trả về một bảng trong đó cho biết tổng số lượng hàng bán được của mỗi mặt hàng. 
--Sử dụng hàm này để thống kê xem tổng số lượng hàng (hiện có và đã bán) của mỗi mặt hàng là bao nhiêu. 
create function fn_ThongKeSoLuong()
returns table
as
return 
(
    select mh.mahang,
           mh.tenhang,
           SUM(CTDH.soluong) TongSoLuongBan
    from MATHANG mh
    JOIN CHITIETDONHANG CTDH ON MH.mahang = CTDH.mahang
    group by MH.mahang, MH.tenhang
)
go
-- Sử dụng hàm để thống kê tổng số lượng hàng hiện có và đã bán
select mh.mahang,
       mh.tenhang,
	   mh.soluong,
       mh.soluong - ISNULL(tk.TongSoLuongBan, 0)  SoLuongHienCo,
       ISNULL(tk.TongSoLuongBan, 0) 'Tổng số lượng đã bán'
from MATHANG mh
LEFT JOIN fn_ThongKeSoLuong() tk ON mh.mahang = tk.mahang

go
--3.1)Viết trigger cho bảng CHITIETDATHANG theo yêu cầu sau: 
--Khi một bản ghi mới được bổ sung vào bảng này thì giảm số lượng hàng hiện có nếu số lượng hàng hiện có lớn hơn hoặc bằng số lượng hàng được bán ra. 
--Ngược lại thì huỷ bỏ thao tác bổ sung. 
create trigger tg_CTDH_Insert
on CHITIETDONHANG
after insert 
as
begin
	if exists (
		select 1
		from MATHANG mh
		JOIN inserted i on mh.mahang = i.mahang
		where mh.soluong < i.soluong or i.soluong < 0)
	begin
        RAISERROR ('Số lượng đặt vượt quá tồn kho hoặc số lượng đặt không hợp lệ!', 16, 1);
        rollback transaction
    end
	else
	begin
        UPDATE mh
        set mh.soluong = mh.soluong - i.soluong
        from MATHANG mh
        JOIN inserted i ON mh.mahang = i.mahang;

		-- Cập nhật giá bán
		UPDATE CHITIETDONHANG
		set giaban = m.giahang
		FROM inserted AS i
		JOIN MATHANG m
		ON i.MAHANG = m.MAHANG
		WHERE i.sohoadon = CHITIETDONHANG.sohoadon
    end
end
go 
-- Dữ liệu hợp lệ
insert into CHITIETDONHANG
values ('HD010','MH003',0,100,0)

-- Dữ liệu không hợp lệ
--insert into CHITIETDONHANG
--values ('HD001','MH011',0,100,0)

