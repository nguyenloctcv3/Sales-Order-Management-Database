USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'NVL_5215')
BEGIN
    ALTER DATABASE NVL_5215 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE NVL_5215;
END

create database NVL_5215;
go
use NVL_5215;

-- 1. Khách hàng
create table KhachHang (
    maKH varchar(10) primary key,
    tenKH nvarchar(100),
    diaChiKH nvarchar(200),
    SDT varchar(15),
    Email varchar(100),
    soDuTaiKhoan money
);
go


-- 2. Nhà cung cấp
create table NhaCungCap (
    maNCC varchar(10) primary key,
    tenNCC nvarchar(100),
    diaChiNCC nvarchar(200),
    SDT varchar(15),
    nhanVienLienHe nvarchar(100)
);
go


-- 3. Nhân viên
create table NhanVien (
    maNV varchar(10) primary key,
    tenNV nvarchar(100),
    SDT varchar(15),
    Email varchar(100),
    gioiTinh bit,
    DoB date,
    Salary money
);
go

-- 4. Sản phẩm
create table SanPham (
    maSP char(7) primary key,
    tenSP nvarchar(100),
    donGiaBan money,
    soLuongHienCon bigint,
    soLuongCanDuoi smallint
);
go

-- 5. Phiếu nhập
create table PhieuNhap (
    mapN char(7) primary key,
    ngayNhapHang datetime,
    maNCC varchar(10)
);
go

-- 6. Chi tiết phiếu nhập
create table ChiTietPhieuNhap (
    mapN char(7),
    maSP char(7),
    soLuongNhap int,
    giaNhap money,
    primary key (mapN, maSP)
);
go

-- 7. Đơn đặt hàng hóa đơn
create table DonDatHang_HoaDon (
    maDH varchar(10) primary key,
    ngayTaoDH datetime,
    diaChiGiaoHang nvarchar(200),
    SDTGiaoHang varchar(15),
    maHoaDonDienTu varchar(50),
    ngayThanhToan datetime,
    ngayGiaoHang datetime,
    trangThaiDonHang NVARCHAR(50),
    maKH varchar(10),
    maNV varchar(10)
);
go

-- 8. Chi tiết đơn hàng
create table ChiTietDonHang (
    maDH varchar(10),
    maSP char(7),
    soLuongDat int,
    donGia money,
    primary key (maDH, maSP)
);
go
-- BỔ SUNG THÊM CÁC BẢNG BỔ TRỢ
-- 9. Khuyến Mãi
create table KhuyenMai (
    maKM varchar(10) primary key,
    tenKM nvarchar(100) NOT NULL,
    phanTramGiam decimal(5,2) NOT NULL,
    ngayBatDau date NOT NULL,
    ngayKetThuc date NOT NULL
);
go
-- 10. Bảng Chức Vụ
create table ChucVu (
    maCV varchar(10) NOT NULL primary key,
    tenCV nvarchar(50) NOT NULL
);
go

-- 11. Bảng Nhân Viên Chức Vụ 
create table NhanVien_ChucVu (
    maNV varchar(10) NOT NULL,
    maCV varchar(10) NOT NULL,
    ngayNhanChuc DATE DEFAULT GETDATE(),
    primary key (maNV, maCV)
);
go
-- Tách cột Địa chỉ trong KhachHang 
alter table KhachHang 
    add 
        soNhaTenDuong nvarchar(100),
        phuongXa nvarchar(50),
        quanHuyen nvarchar(50),
        tinhThanhPho nvarchar(50);
go

alter table KhachHang
drop column tinhThanhPho, quanHuyen;
go
-- Bổ sung cột trangThaiDonHang vào bảng DonDatHang_HoaDon
alter table DonDatHang_HoaDon
    add constraint CK_DonDatHang_trangThaiDonHang
        check (trangThaiDonHang IN( 
            N'Chờ duyệt',
            N'Đã duyệt - Đang đóng gói',
            N'Đang giao',
            N'Đã giao'
));
go 
-- TẠO DATABASE CHO BÀI TOÁN
-- 1. Email: có chứa @, bắt đầu là chữ cái viết thường hoặc viết hoa (thuộc 1 trong 3 dịch vụ mail: Gmail hoặc Yahoo Mail hoặc ute.udn.vn mail); và phải là duy nhất 
alter table KhachHang 
add
    -- Ràng buộc kiểm tra định dạng email và 3 domain hợp lệ
    constraint CK_KhachHang_Email check (
        Email like'[a-zA-Z]%@gmail.com' or 
        Email like '[a-zA-Z]%@yahoo.com' or 
        Email like '[a-zA-Z]%@ute.udn.vn'
    ),
    -- Ràng buộc đảm bảo email không bị trùng lắp (duy nhất)
    constraint UQ_KhachHang_Email unique (Email);
go
-- 2. TelNo là dãy các chữ số gồm 10 hoặc 11 chữ số, và phải đảm bảo duy nhất 
-- Bảng KhachHang
alter table KhachHang 
	add 
        constraint CK_KhachHang_SDT check (
		    SDT like '0[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
			    or SDT like '0[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
        constraint UQ_KhachHang_SDT UNIQUE (SDT);
go
-- bảng NhanVien 
alter table NhanVien  
	add 
        constraint CK_NhanVien_SDT check (
		    SDT like '0[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
			    or SDT like '0[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
        constraint UQ_NhanVien_SDT UNIQUE (SDT);
go
-- 3. DoB đảm bảo đủ 18 tuổi trở lên
alter table NhanVien
    add constraint CK_NhanVien_DoB check (
        DoB <= dateadd(year, -18, getdate())
    );
go

-- 4. Gender (‘F’ hoặc ‘M’) – mặc định ‘F’ 
alter table NhanVien
    alter column gioiTinh char(1);
alter table NhanVien
    add
        constraint CK_NhanVien_gioiTinh check( gioiTinh in ('M', 'F')),
        constraint DF_NhanVien_gioiTinh default 'F' for gioiTinh;
go

-- 5. Position chỉ nhận một trong các giá trị sau: ‘Nhân viên bán hàng’, ‘Nhân viên kho’,
--‘Nhân viên giao hàng’, ‘Quản lý viên’. Mặc định là ‘Nhân viên bán hàng’ 
alter table ChucVu
    add
        constraint CK_ChucVu_tenCV check(tenCV in(
        N'Nhân viên bán hàng', 
        N'Nhân viên kho', 
        N'Nhân viên giao hàng', 
        N'Quản lí viên')
        ),
        constraint DF_ChucVu_tenCV default N'Nhân viên bán hàng' for tenCV;
go


--Thực hiện trên bảng DonDatHang_HoaDon
--6.  OrderDate(ngaytaoDH): nhỏ hơn ngày hiện tại 
alter table DonDatHang_HoaDon
    add constraint CK_DonDatHang_HoaDon_ngaytaoDH check(
        ngaytaoDH < getdate());
go
--7. InvDate(ngayThanhToan) : nhỏ hơn ngày hiện tại và lớn hơn OrderDate (ngaytaoDH)
alter table DonDatHang_HoaDon
    add 
        constraint CK_DonDatHang_HoaDon_ngayThanhToan check(
        ngayThanhToan < getdate() and
        ngaythanhToan >= ngaytaoDH);
go
--8. DelDate(ngayGiaoHang): nhỏ hơn ngày hiện tại và lớn hơn InvDate(ngayThanhToan)
alter table DonDatHang_HoaDon
    add
        constraint CK_DonDatHang_HoaDon_ngayGiaoHang check(
            ngayGiaoHang < getdate() and
            ngayGiaoHang >= ngayThanhToan);
go
--9.  DelStatus: (‘BT’ – nghĩa là bình thường, hoặc ‘ER’ – là lỗi hàng,
--hoặc ‘LL’ – Không liên lạc được với khách hàng) – mặc định ‘Bình thường’ 
--Thêm DelStatus vào bảng DonDatHang_HoaDon
alter table DonDatHang_HoaDon
add DelStatus varchar(5);
go

alter table DonDatHang_HoaDon
alter column DelStatus nvarchar(15);
go

alter table DonDatHang_HoaDon
add 
    constraint CK_DonDatHang_HoaDon_DelStatus check(DelStatus in(
        'BT', 
        'ER',
        'LL',
        N'Bình thường')
    ),
    constraint DF_DonDatHang_HoaDon_DelStatus default N'Bình thường' for DelStatus;
go

--10. Address (‘Đà Nẵng’, ‘TP Hồ Chí Minh’, ‘Quảng Nam’) – mặc định ‘Đà Nẵng’ 
--Cho bảng: tblSupplier(NhaCungCap), tblCustomer(KhachHang)
--NhaCungCap
alter table NhaCungCap
    add
        constraint CK_NhaCungCap_diaChiNCC check(diachiNCC in(
            N'Đà Nẵng',
            N'TP Hồ Chí Minh',
            N'Quảng Nam')
        ),
        constraint DF_NhaCungCap_diaChiNCC default N'Đà Nẵng' for diaChiNCC;
go

--KhachHang
alter table KhachHang 
    add 
        constraint CK_KhachHang_diaChiKH check(diaChiKH in(
            N'Đà Nẵng',
            N'TP Hồ Chí Minh', 
            N'Quảng Nam')
        ),
        constraint DF_KhachHang_diaChiKH default N'Đà Nẵng' for diaChiKH;
go
--11. Các column liên quan đến số lượng hoặc giá tiền: đảm bảo lớn hơn hoặc bằng 0 
--tblCustomer(Balance) <-> KhachHang(soDuTaiKhoan)
alter table KhachHang 
    add constraint CK_KhachHang_soDuTaiKhoan check(
        soDuTaiKhoan >= 0);
go
--tblEmployee(Salary) <--> NhanVien(Salary)
alter table NhanVien 
    add constraint CK_NhanVien_Salary check(
        Salary >=0);
go
--tblOrderInvoice(OrderTotalMoney) <--> DonDatHang_HoaDon(tongTienDonHang)
--Thêm cột tongTienDonHang 
alter table DonDatHang_HoaDon
    add tongTienDonHang MONEY not null constraint DF_DonDatHang_HoaDon_tongTienDonHang default 0;
go
--Thêm ràng buộc cho tongTienDonHang
alter table DonDatHang_HoaDon
    add constraint CK_DonDatHang_HoaDon_tongTienDonHang check(
        tongTienDonHang >= 0);
go
--tblOrderInvoiceDetail(QtyOrdered,Amount) <--> ChiTietDonHang(soLuongDat, donGia)
alter table ChiTietDonHang
    add     
        constraint CK_ChiTietDonHang_soLuongDat check(
            soLuongDat >= 0),
        constraint CK_ChiTietDonHang_donGia check(
            donGia >= 0);
go
--tblProduct(QtyOnHand,UnitPrice,RecorderLevel) <--> SanPham(soLuongHienCon, donGiaBan, soLuongCanDuoi)
alter table SanPham 
    add
        constraint CK_SanPham_soLuongHienCon check(
            soLuongHienCon >= 0),
        constraint CK_SanPham_donGiaban check(
            donGiaBan >= 0),
        constraint CK_SanPham_soLuongCanDuoi check(
            soLuongCanDuoi >= 0);
go
--12. Tất cả các khóa ngoại nên thiết lập ràng buộc phụ thuộc khi Xóa/Update 
-- Bảng ChiTietDonHang
alter table ChiTietDonHang
    add 
        constraint FK_ChiTietDonHang_maDH foreign key(maDH)
            references DonDatHang_HoaDon (maDH)
            on update cascade
            on delete cascade,
        constraint FK_ChiTietDonHang_maSP foreign key(maSP)
            references SanPham(maSP)
            on update cascade 
            on delete cascade;
go
-- Bảng ChiTietPhieuNhap
alter table ChiTietPhieuNhap
    add
        constraint FK_ChiTietPhieuNhap_mapN foreign key(mapN) 
            references PhieuNhap(mapN)
            on update cascade 
            on delete cascade,
        constraint FK_ChiTietPhieuNhap_maSP foreign key(maSP)
            references SanPham(maSP)
            on update cascade
            on delete cascade;
go
--Bảng : DonDatHang_HoaDon
alter table DonDatHang_HoaDon
    add
        constraint FK_DonDatHang_HoaDon_maKH foreign key(maKH)
            references KhachHang(maKH)
            on update cascade
            on delete cascade,
        constraint FK_DonDatHang_HoaDon_maNV foreign key(maNV)
            references NhanVien(maNV)
            on update cascade
            on delete cascade;
go
-- Bảng NhanVien_ChucVu
alter table NhanVien_ChucVu 
    add
        constraint FK_NhanVien_ChucVu_maCV foreign key(maCV)
            references ChucVu(maCV)
            on update cascade
            on delete cascade,
        constraint FK_NhanVien_ChucVu_maNV foreign key(maNV)
            references NhanVien(maNV)
            on update cascade 
            on delete cascade;
go
--Bảng : PhieuNhap
alter table PhieuNhap
    add constraint FK_PhieuNhap_maNCC foreign key (maNCC)
        references NhaCungCap(maNCC)
        on update cascade
        on delete cascade;
go 
--13. Sử dụng identity 
drop table KhuyenMai;
create table KhuyenMai (
    maKM int identity primary key,
    tenKM nvarchar(100) NOT NULL,
    phanTramGiam decimal(5,2) NOT NULL,
    ngayBatDau date NOT NULL,
    ngayKetThuc date NOT NULL
);
go 
-- THÊM DỮ LIỆU CHO TẤT CẢ CÁC BẢNG
--1. Sử dụng lệnh set dateformat để đảm bảo thứ tự dữ liệu day-month-year có thể chạy đúng trên mọi máy tính;
set dateformat dmy
go

--2. Bảng SanPham
insert into SanPham
    (maSP, tenSP, donGiaBan, soLuongHienCon, soLuongCanDuoi)
values
    ('2150001', N'Gạo', 145000, 30, 5),
    ('2150002', N'Sữa tươi Vinamilk', 25000, 50, 10),
    ('2150003', N'Dầu ăn', 55000, 25, 5),
    ('2150004', N'Đường', 12000, 50, 10),
    ('2150005', N'Mì tôm Hảo Hảo', 4500, 100,20),
    ('2150006', N'Trứng gà', 3000, 100, 20),
    ('2150007', N'Nước suối Aquafina', 5000, 50, 5),
    ('2150008', N'Nước giặt OMO', 125000, 20, 5),
    ('2150009', N'Nước mắm Nam Ngư', 32000, 40, 10),
    ('2150010', N'Nước rửa chén Sunlight', 32000, 25, 5)
go
--3. Bảng ChucVu
insert into ChucVu
    (maCV, tenCV)
values
    ('CV001',N'Nhân viên bán hàng'),
    ('CV002',N'Nhân viên kho'),
    ('CV003',N'Nhân viên giao hàng'),
    ('CV004',N'Quản lí viên')
go
--4. Bảng KhuyenMai
set dateformat dmy
insert into KhuyenMai
    (tenKM, phanTramGiam, ngayBatDau, ngayKetThuc)
values
    (N'Giảm giá khai trương', 10.00, '01/01/2026', '31/01/2026'),
    (N'Khuyến mãi đầu năm', 15.50, '05/01/2026', '05/02/2026'),
    (N'Ưu đãi khách hàng mới', 5.00, '01/02/2026', '28/05/2026'),
    (N'Giảm giá mùa xuân', 10.00, '01/03/2026', '31/03/2026'),
    (N'Khuyến mãi ngày lễ', 25.50, '25/04/2026', '05/05/2026'),
    (N'Ưu đãi tháng 5', 10.50, '01/05/2026', '31/05/2026'),
    (N'Giảm giá mùa hè', 20.00, '01/06/2026', '30/06/2026'),
    (N'Khuyến mãi tháng 7', 15.75, '01/07/2026', '31/07/2026'),
    (N'Ưu đãi đặc biệt', 40.00, '01/08/2026', '05/08/2026'),
    (N'Đại tiệc giảm giá', 50.00, '01/09/2026', '03/09/2026')
go
--5. Bảng NhaCungCap
insert into NhaCungCap
    (maNCC, tenNCC, diaChiNCC, SDT, nhanVienLienHe)
values
    ('NCC001', N'Công ty TNHH Minh Phát', default, '02363812345', N'Trần Văn Nam 0905123456'),
    ('NCC002', N'Công ty TNHH An Phú', N'Đà Nẵng', '02363567891', N'Lê Thị Mai 0914123456'),
    ('NCC003', N'Công ty CP Đại Thành', N'TP Hồ Chí Minh', '02363781234', N'Phạm Văn Hùng 0935123456'),
    ('NCC004', N'Công ty TNHH Hoàng Gia', N'Quảng Nam', '02363876543', N'Nguyễn Thị Lan 0905123789'),
    ('NCC005', N'Công ty CP Phú Hưng', N'TP Hồ Chí Minh', '02363912345', N'Võ Minh Tuấn 0915123789'),
    ('NCC006', N'Công ty TNHH Thành Công', default, '02363765432', N'Đặng Thị Hương 0945123789'),
    ('NCC007', N'Công ty CP Hưng Thịnh', default, '02363823456', N'Bùi Văn Đức 0905123890'),
    ('NCC008', N'Công ty TNHH Tân Tiến', N'Quảng Nam', '02363987654', N'Phan Thị Thảo 0925123890'),
    ('NCC009', N'Công ty CP Việt Thành', N'TP Hồ Chí Minh', '02363834567', N'Hồ Quốc Bảo 0935123890'),
    ('NCC010', N'Công ty TNHH Thành Đạt', N'TP Hồ Chí Minh', '02363845678', N'Đỗ Minh Tâm 0945123891')
go
--6. Bảng NhanVien
insert into NhanVien
    (maNV, tenNV, SDT, Email, gioiTinh, DoB, Salary)
values
    ('NV001', N'Nguyễn Hoàng Gia Hưng', '0905123456', 'giahung@gmail.com', 'M', '15/05/2007', 12000000),
    ('NV002', N'Nguyễn Anh Huy', '0915123456', 'anhhuy@yahoo.com', 'M', '20/08/2007', 11000000),
    ('NV003', N'Trần Gia Huy', '0925123456', 'giahuy@gmail.com', 'M', '10/03/2007', 13000000),
    ('NV004', N'Nguyễn Phan An Kha', '0935123456', 'ankha@gmail.com', 'M', '25/11/2007', 11500000),
    ('NV005', N'Nguyễn Văn Lộc', '0945123456', 'nguyenloc.tcv3@gmail.com', 'M', '09/01/2007', 14000000),
    ('NV006', N'Trần Hoàng Long', '0965123456', 'hoanglong@gmail.com', 'M', '18/02/2007', 10500000),
    ('NV007', N'Trần Công Luật', '0975123456', 'congluat@gmail.com', 'M', '30/09/2007', 15000000),
    ('NV008', N'Phạm Văn Mạnh', '0985123456', 'vanmanh@gmail.com', 'M', '05/04/2007', 10000000),
    ('NV009', N'Trần Văn Tuấn Minh', '0906123456', 'tuanminh09@gmail.com', 'M', '22/12/2007', 12500000),
    ('NV010', N'Hồ Kiều My', '0916123456', 'kieumy@gmail.com', 'F', '14/06/2007', 11000000)
go
--7. Bảng KhachHang
insert into KhachHang
    (maKH, tenKH, diaChiKH, SDT, Email, soDuTaiKhoan, soNhaTenDuong, phuongXa)
values
    ('KH0001', N'Nguyễn Hoàng Gia Hưng',default, '0964106319', 'hunggia@gmail.com', 
    136000, N'1629 Nguyễn Tất Thành', N'Thanh Khê'),
    ('KH0002', N'Nguyễn Anh Huy',N'TP Hồ Chí Minh', '0934406323', 'huyanh@gmail.com', 
    1200000, N'16 Lê Lợi', N'Quận Thanh Bình'),
    ('KH0003', N'Trần Gia Huy',N'Quảng Nam', '0799102303', 'huygia@gmail.com', 
    1000000, N'100 Đỗ Thế Chấp', N'Hương Trà'),
    ('KH0004', N'Nguyễn Phan An Kha',default, '0799314341', 'khaan@gmail.com', 
    235000, N'379 Trần Cao Vân', N'Thanh Khê'),
    ('KH0005', N'Nguyễn Văn Lộc',default, '0363918213', 'vanloc@gmail.com', 
    460000, N'149 Lê Đình Lý', N'Hải Châu'),
    ('KH0006', N'Trần Hoàng Long',default, '0395792224', 'longhoang@gmail.com', 
    500000, N'16 Đống Đa', N'Hải Châu'),
    ('KH0007', N'Trần Công Luật',default, '0345184896', 'luatcong@gmail.com', 
    356000, N'82 Điện Biên Phủ', N'Thanh Khê'),
    ('KH0008', N'Phạm Văn Mạnh',default, '0383589777', 'manhvan@gmail.com', 
    180000, N'54/28 Nguyễn Phước Nguyên', N'Thanh Khê'),
    ('KH0009', N'Trần Văn Tuấn Minh',default, '0722325523', 'minhtuan@gmail.com', 
    325000, N'56 Tôn Đức Thắng', N'Hòa Khánh'),
    ('KH0010', N'Hồ Kiều My ',N'Quảng Nam', '0363218238', 'mykieu@gmail.com', 
    200000, N'98 Huỳnh Thúc Kháng', N'Hương Trà')
go
--8. Bảng PhieuNhap
insert into PhieuNhap
    (mapN, ngayNhapHang, maNCC)
values
    ('5210001', '27/09/2026', 'NCC001'),
    ('5210002', '27/09/2026', 'NCC001'),
    ('5210003', '28/09/2026', 'NCC005'),
    ('5210004', '29/09/2026', 'NCC002'),
    ('5210005', '02/10/2026', 'NCC003'),
    ('5210006', '02/10/2026', 'NCC010'),
    ('5210007', '05/10/2026', 'NCC007'),
    ('5210008', '07/10/2026', 'NCC004'),
    ('5210009', '08/10/2026', 'NCC009'),
    ('5210010', '12/10/2026','NCC002')
go
alter table DonDatHang_HoaDon
    add phuongXaGiaoHang nvarchar(50);
go
--9. Bảng DonDatHang_HoaDon
insert into DonDatHang_HoaDon (maDH, ngayTaoDH, diaChiGiaoHang, SDTGiaoHang, maHoaDonDienTu, ngayThanhToan, ngayGiaoHang, trangThaiDonHang, maKH, maNV, DelStatus, tongTienDonHang, phuongXaGiaoHang)
values
    ('NVL001', '16/09/2026', N'1629 Nguyễn Tất Thành, Thanh Khê, TP Đà Nẵng', '0964106319', 'HD001', '27/09/2026', '05/10/2026', N'Đã giao', 'KH0003', 'NV001', N'Bình thường', 290000, N'Thanh Khê'),
    ('NVL002', '02/08/2026', N'120 Điện Biên Phủ, Thanh Khê, TP Đà Nẵng', '0964106319', 'HD002', '27/09/2026', '05/10/2026', N'Đang giao', 'KH0003', 'NV001', 'BT', 435000, N'Thanh Khê'),
    ('NVL003', '16/09/2026', N'45 Lê Duẩn, Hải Châu, TP Đà Nẵng', '0964106319', 'HD003', '27/09/2026', '05/10/2026', N'Đã duyệt - Đang đóng gói', 'KH0003', 'NV001', 'ER', 145000, N'Hải Châu'),
    ('NVL004', '18/09/2026', N'88 Ngô Quyền, Sơn Trà, TP Đà Nẵng', '0912345678', 'HD004', NULL, NULL, N'Chờ duyệt', 'KH0001', 'NV002', 'LL', 200000, N'An Hải Bắc'),
    ('NVL005', '20/09/2026', N'12 Nguyễn Văn Linh, Hải Châu, TP Đà Nẵng', '0912345678', 'HD005', '29/09/2026', '07/10/2026', N'Đã giao', 'KH0001', 'NV002', N'Bình thường', 150000, N'Hải Châu'),
    ('NVL006', '21/09/2026', N'50 Dũng Sĩ Thanh Khê, Thanh Khê, Đà Nẵng', '0988777666', 'HD006', '30/09/2026', '08/10/2026', N'Đang giao', 'KH0002', 'NV001', 'BT', 300000, N'Thanh Khê'),
    ('NVL007', '22/09/2026', N'101 Tôn Đức Thắng, Liên Chiểu, Đà Nẵng', '0935111222', 'HD007', NULL, NULL, N'Chờ duyệt', 'KH0004', 'NV003', 'ER', 145000, N'Hòa Khánh Bắc'),
    ('NVL008', '23/09/2026', N'205 Cách Mạng T8, Cẩm Lệ, TP Đà Nẵng', '0905333444', 'HD008', '02/10/2026', '10/10/2026', N'Đã duyệt - Đang đóng gói', 'KH0005', 'NV001', 'LL', 290000, N'Khuê Trung'),
    ('NVL009', '24/09/2026', N'77 Lương Nhữ Hộc, Cẩm Lệ, TP Đà Nẵng', '0905333444', 'HD009', '03/10/2026', '11/10/2026', N'Đã giao', 'KH0005', 'NV003', N'Bình thường', 100000, N'Khuê Trung'),
    ('NVL010', '25/09/2026', N'300 Trần Hưng Đạo, Sơn Trà, TP Đà Nẵng', '096410699', 'HD010', '04/10/2026', '12/10/2026', N'Đang giao', 'KH0006', 'NV002', 'BT', 250000, N'An Hải Bắc')
go
--10. Bảng NhanVien_ChucVu
insert into NhanVien_ChucVu
    (maNV, maCV, ngayNhanChuc)
values
    ('NV001', 'CV004', '09/01/2023'),
    ('NV002', 'CV001', '25/03/2023'),
    ('NV002', 'CV002', '26/09/2023'),
    ('NV002', 'CV004', '12/04/2024'),
    ('NV003', 'CV001', '12/04/2024'),
    ('NV004', 'CV003', '18/09/2024'),
    ('NV005', 'CV003', '20/09/2024'),
    ('NV006', 'CV002', '25/03/2025'),
    ('NV007', 'CV002', '25/03/2025'),
    ('NV008', 'CV003', '02/08/2025'),
    ('NV009', 'CV001', '25/03/2026'),
    ('NV010', 'CV001', '25/03/2026')
go
--11. Bảng ChiTietDonHang
insert into ChiTietDonHang
    (maDH, maSP, soLuongDat, donGia)
values
    ('NVL001', '2150001', 1, 145000), 
    ('NVL001', '2150002', 1, 25000), 
    ('NVL002', '2150001', 3, 145000),
    ('NVL003', '2150001', 1, 145000),
    ('NVL004', '2150002', 2, 25000),
    ('NVL005', '2150003', 1, 55000),
    ('NVL006', '2150001', 2, 145000),
    ('NVL007', '2150001', 1, 145000),
    ('NVL008', '2150002', 2, 25000),
    ('NVL009', '2150003', 1, 55000),
    ('NVL010', '2150001', 1, 145000);
go
--12. Bảng ChiTietPhieuNhap
insert into ChiTietPhieuNhap
    (mapN, maSP, soLuongNhap, giaNhap)
values
    ('5210001', '2150001', 100, 100000),
    ('5210001', '2150002', 200, 18000),
    ('5210002', '2150003', 150, 40000),
    ('5210003', '2150004', 300, 8000),
    ('5210004', '2150005', 500, 3000),
    ('5210005', '2150006', 400, 2000),
    ('5210006', '2150007', 250, 3500),
    ('5210007', '2150008', 100, 90000),
    ('5210008', '2150009', 150, 22000),
    ('5210009', '2150010', 120, 22000)
go
-- ==========================================================================================================
-- TRUY VẤN DỮ LIỆU
-- ==========================================================================================================
-- C1: Dùng from + where and subquery 
-- 1. Hãy hiển thị thông tin các sản phẩm nằm trông 3 mức giá cao nhất
select * 
from SanPham 
where donGiaBan in(
    select distinct top 3 donGiaBan 
    from SanPham
    order by donGiaBan desc
);
go

-- 2. Hãy hiện thị thông tin sản phẩm có số lần nhập hàng về nhiều nhất
insert into ChiTietPhieuNhap
    (mapN, maSP, soLuongNhap, giaNhap)
values
    ('5210010', '2150003', 100, 400000)
go

select top 1 with ties count(ct.maSP) as soLanNhap, tenSP, donGiaBan, soLuongHienCon, soLuongCanDuoi 
from SanPham sp, ChiTietDonHang ct
where sp.maSP = ct.maSP
group by ct.maSP, tenSP, donGiaBan, soLuongHienCon, soLuongCanDuoi 
order by count(ct.maSP) desc;
go

-- 3. Thống kê sản phẩm ở top3 bán chạy nhất (có thể đảm bảo nhiều dòng miễn là đảm bảo nằm trong top3)
select top 3 with ties sum(ct.soLuongDat) as tongSoLuongDat, ct.maSP, tenSP
from SanPham sp, ChiTietDonHang ct
where sp.maSP = ct.maSP
group by ct.maSP, tenSP
order by tongSoLuongDat desc;
go
-- subquery 
select *
from SanPham sp 
where maSP in(
    select top 3 with ties ct.maSP
    from ChiTietDonHang ct
    group by ct.maSP
    order by sum(ct.soLuongDat) desc
);

-- 4. Thống kê những sản phẩm chưa được bán cái nào not in 
select * 
from SanPham 
where maSP not in(
    select maSP
    from ChiTietDonHang 
    where maSP is not null
);
go

-- 5. Hiển thị những đơn hàng giao thành công và thông tin cụ thể của người giao hàng (position)
-- Những đơn hàng giao thành công
select ddh.maDH, trangThaiDonHang, nv.maNV, tenNV, gioiTinh, DoB, Salary 
from DonDatHang_HoaDon ddh,  NhanVien nv
where nv.maNV = ddh.maNV
and trangThaiDonHang in (N'Đã giao');
go

-- 6. Hiển thị những đơn hàng của khách hàng ở Đà Nẵng hoặc ở Quảng Nam (nên có điều 
-- kiện DN và QN, mặc định là DN hoặc QN)
select maDH, kh.maKH, tenKH, diachiKH
from DonDatHang_HoaDon ddh, KhachHang kh 
where kh.maKH = ddh.maKH
and diaChiKH in (N'Đà Nẵng', N'Quảng Nam', 'DN', 'QN');
go

-- 7. Hiển thị những sản phẩm có giá từ 500k - 2.000k 
insert into SanPham 
    (maSP, tenSP, donGiaBan, soLuongHienCon, soLuongCanDuoi)
values
    ('2150011', N'Rượu vang nhập khẩu', 1800000, 10, 5),
    ('2150012', N'Nấm Linh Chi', 600000, 20, 10),
    ('2150013', N'Đông Trùng Hạ Thảo', 1000000, 10, 5);
go
select maSP, tenSP, format(donGiaBan / 1000, '##,#k', 'es-ES') as donGia, soLuongHienCon, soLuongCanDuoi
from SanPham 
where donGiaBan between 500000 and 2000000;
go

-- 8. Những tháng có doanh thu trên 2000000 (có tham số là định mức tiền)
-- Khai báo biến định mức tiền
insert into DonDatHang_HoaDon
    (maDH, ngayTaoDH, diaChiGiaoHang, SDTGiaoHang, maHoaDonDienTu, ngayThanhToan, ngayGiaoHang, trangThaiDonHang, maKH, maNV, DelStatus, tongTienDonHang, phuongXaGiaoHang)
values
    ('NVL011', '16/09/2026', N'1629 Nguyễn Tất Thành, Thanh Khê, TP Đà Nẵng', '0964106319', 'HD001', '27/09/2026', '05/10/2026', N'Đã giao', 'KH0003', 'NV001', N'Bình thường', 2900000, N'Thanh Khê');
go
declare @dinhMucTien money = 2000000;
-- 9. Hãy tính tổng tiền của từng tháng 
select sum(tongTienDonHang) as doanhThuHangThang, month(ngayThanhToan) as thang, year(ngayThanhToan) nam
from DonDatHang_HoaDon
group by month(ngayThanhToan), year(ngayThanhToan)
having sum(tongTienDonHang) > @dinhMucTien;
go

-- 10. Thống kê số lượng khách theo từng tỉnh / thành phố (sắp xếp giảm dần)
select * from KhachHang
select count(maKH) as soLuongKhachTungTinh, diaChiKH
from KhachHang
group by diaChiKH
order by soLuongKhachTungTinh desc;
go

-- 11. Thống kê giá trung bình, giá max, giá min nhập hàng cho mỗi sản phẩm
-- Thêm dữ liệu vào bảng ChiTietPhieuNhap
insert into ChiTietPhieuNhap (mapN, maSP, soLuongNhap, giaNhap)
values
    ('5210003', '2150001', 200, 900000),
    ('5210004', '2150001', 150, 1100000);
go
select sp.maSP, tenSP, avg(giaNhap) as giaTrungBinh, max(giaNhap) as giaMax, min(giaNhap) as giaMin
from SanPham sp, ChiTietPhieuNhap ct
where sp.maSP = ct.maSP
group by sp.maSP, tenSP;
go 

-- 12. hiển thị giá trung bình, giá max, giá min bán ra cho mỗi sản phẩm 
-- (lưu ý, mỗi mức giá bán ra của sản phẩm chỉ tính 1 lần)  
update ChiTietDonHang
set donGia = 140000
where maDH = 'NVL002' and maSP = '2150001';
update ChiTietDonHang
set donGia = 150000
where maDH = 'NVL003' and maSP = '2150001';
select sp.maSP, tenSP, avg(distinct ct.donGia) as giaTrungBinh, max(ct.donGia) as giaMax, min(ct.donGia) as giaMin
from SanPham sp, ChiTietDonHang ct
where sp.maSP = ct.maSP
group by sp.maSP, sp.tenSP
go

-- 13. Thống kê số lần khách hàng mua hàng của từng khách hàng (sắp xếp giảm dần)
select kh.maKH, tenKH, count(ddh.maKH) as soLanMuaHang
from KhachHang kh
left join DonDatHang_HoaDon ddh on kh.maKH = ddh.maKH
group by kh.maKH, tenKH
order by count(ddh.maKH) desc;
go

-- 14. Hiển thị thông tin chi tiết của các sản phẩm mà có số lần nhập hàng nhiều nhất 
-- (luu ý trường hợp những sản phẩm cùng giá trị)
-- Chèn thêm 1 lần nhập nữa cho Gạo để nâng soLanNhap của Gạo lên 2 lần
insert into ChiTietPhieuNhap (mapN, maSP, soLuongNhap, giaNhap)
values ('5210002', '2150001', 300, 100000);
select top 1 with ties 
    sp.*, 
    count(ct.maSP) as soLanNhap
from SanPham sp, ChiTietPhieuNhap ct
where sp.maSP = ct.maSP
group by sp.maSP, tenSP, donGiaBan, soLuongHienCon, soLuongCanDuoi
order by count(ct.maSP) desc;
go

-- 15. hiển thị thông tin chi tiết của các nhà cung cấp mà có số lần nhập hàng lớn hơn 3 
insert into PhieuNhap 
    (mapN, ngayNhapHang, maNCC)
values 
    ('5210015', '20261031', 'NCC001'),
    ('5210016', '20261031', 'NCC001'),
    ('5210017', '20261031', 'NCC001');
go
select count(ncc.maNCC) as soLanNhapHang, ncc.*
from NhaCungCap ncc, PhieuNhap pn
where ncc.maNCC = pn.maNCC
group by ncc.maNCC, tenNCC, diaChiNCC, SDT, nhanVienLienHe
having count(ncc.maNCC) > 3;
go

-- 16. Hiển thị những đơn hàng không cần được xuất hóa đơn (nghĩa là cột hóa đơn điện tử (kh có gtri)
insert into DonDatHang_HoaDon
    (maDH, ngayTaoDH, diaChiGiaoHang, SDTGiaoHang, maHoaDonDienTu, trangThaiDonHang, maKH)
values 
    ('NVL012', '20261101', N'Đà Nẵng', '0905123456', NULL, N'Đã giao', 'KH0001');
go
select *
from DonDatHang_HoaDon
where maHoaDonDienTu is null;
go
-- C2: Sử dụng join / union / except
-- 1. Hãy hiển thị thông tin các sản phẩm có giá bán ra nằm trong 3 mức giá cao nhất?
select distinct s.maSP, tenSP, c.donGia, soLuongHienCon, soLuongCanDuoi
from SanPham s
inner join ChiTietDonHang c on c.maSP = s.maSP
where c.donGia in (
    select distinct top 3 donGia 
    from ChiTietDonHang 
    order by donGia desc
)
order by c.donGia desc;
go

-- 2. Hãy hiển thị thông tin sản phẩm có số lần nhập hàng về nhiều nhất 
select top 1 with ties 
    s.maSP,
    tenSP,
    soLuongHienCon, 
    soLuongCanDuoi, 
    donGiaBan, 
    count(c.maSP) as soLanNhap
from SanPham s
inner join ChiTietPhieuNhap c on s.maSP = c.maSP 
group by s.maSP, tenSP, soLuongHienCon, soLuongCanDuoi, donGiaBan
order by count(c.maSP) desc;
go

-- 3. thống kê những sản phẩm thuộc top 3 bán chạy nhất  
select s.maSP, tenSP, count(c.maSP) as soLanBan
from SanPham s 
inner join ChiTietDonHang c on c.maSP = s.maSP 
group by s.maSP, tenSP
having count(c.maSP) in (
    select distinct top 3 count(maSP)
    from ChiTietDonHang
    group by maSP
    order by count(maSP) desc
)
order by count(c.maSP) desc;
go

-- 4. thống kê những sản phẩm chưa bán được cái nào  
select s.maSP, tenSP 
from SanPham s
left join ChiTietDonHang c on c.maSP = s.maSP
where c.maSP is null;
go

-- 5. Hiển thị những đơn hàng giao thành công và thông tin cụ thể của người giao hàng (position) 
select * from DonDatHang_HoaDon;
select * from NhanVien;
select d.maDH, d.trangThaiDonHang, n.maNV, n.tenNV, n.SDT, n.Email, n.gioiTinh, n.DoB, n.Salary, c.maCV, tenCV
from DonDatHang_HoaDon d
inner join NhanVien n on n.maNV = d.maNV 
inner join NhanVien_ChucVu nc on nc.maNV = n.maNV
inner join ChucVu c on c.maCV = nc.maCV
where d.trangThaiDonHang = N'Đã giao';
go

-- 6. hiển thị những đơn hàng của khách hàng ở Đà Nẵng hoặc Quảng Nam (nên có điều kiện DN và QN, mặc định là DN hoặc QN) 
select d.maDH, k.maKH, k.tenKH, k.diaChiKH 
from DonDatHang_HoaDon d
inner join KhachHang k on d.maKH = k.maKH 
where k.diaChiKH in (N'Quảng Nam', N'Đà Nẵng')
go

-- 7. hiển thị những sản phẩm có giá từ 500k – 2.000k 
select maSP, tenSP, format(donGiaBan / 1000, '##,#k', 'es-ES') as donGia, soLuongHienCon, soLuongCanDuoi
from SanPham 
where donGiaBan between 500000 and 2000000;
go

-- 8. những tháng có doanh thu trên 2000000 (có tham số là định mức tiền)
declare @dinhMucTien money = 2000000;
select sum(tongTienDonHang) as doanhThu , year(ngayThanhToan) as nam, month(ngayThanhToan) as thang
from DonDatHang_HoaDon
where ngayThanhToan is not null -- Có những đơn hàng chưa thanh toán (đang ở trạng thái chờ duyệt)
group by year(ngayThanhToan), month(ngayThanhToan) 
having sum(tongTienDonHang) > @dinhMucTien
order by sum(tongTienDonHang)
go

-- 9. thống kê số lượng khách theo từng tỉnh/thành phố (sắp xếp giảm dần) 
select diaChiKH, count(maKH) as soLuongKhach
from KhachHang
group by diaChiKH
order by soLuongKhach desc;
go

-- 10. thống kê giá trung bình, giá max, giá min nhập hàng cho mỗi sản phẩm  
select s.maSP, s.tenSP, avg(giaNhap) as giaTrungBinh, max(giaNhap) as giaMax, min(giaNhap) as giaMin 
from SanPham s
inner join ChiTietPhieuNhap c on c.maSP = s.maSP
group by s.maSP, s.tenSP;
go

-- 11. hiển thị giá trung bình, giá max, giá min bán ra cho mỗi sản phẩm (lưu ý, mỗi mức giá bán ra của sản phẩm chỉ tính 1 lần)  
select * from ChiTietDonHang
select s.maSP, s.tenSP, avg(distinct donGia) as giaTrungBinh, max(donGia) as giaMax, min(donGia) as giaMin 
from ChiTietDonHang c
inner join SanPham s on s.maSP = c.maSP 
group by s.maSP, s.tenSP;
go

-- 12. thống kê số lần khách hàng mua hàng của từng khách hàng (sắp xếp giảm dần) 
select k.maKH, k.tenKH, count(d.maDH) as soLanMuaHang 
from DonDatHang_HoaDon d
right join KhachHang k on k.maKH = d.maKH
group by k.maKH, k.tenKH 
order by soLanMuaHang desc;
go

-- 13. hiển thị thông tin chi tiết của các sản phẩm mà có số lần nhập hàng nhiều nhất  
select top 1 with ties count(maPN) as soLanNhapHang, s.maSP, tenSP, soLuongCanDuoi, soLuongHienCon, donGiaBan
from ChiTietPhieuNhap c
inner join SanPham s on s.maSP = c.maSP 
group by s.maSP, tenSP, soLuongCanDuoi, soLuongHienCon, donGiaBan
order by soLanNhapHang desc;
go

-- 14. hiển thị thông tin chi tiết của các nhà cung cấp mà có số lần nhập hàng lớn hơn 1 
select n.maNCC, tenNCC, diaChiNCC, SDT, nhanVienLienHe, count(c.mapN) as soLanNhap
from NhaCungCap n
inner join PhieuNhap c on n.maNCC = c.maNCC
group by n.maNCC, tenNCC, diaChiNCC, SDT, nhanVienLienHe
having count(mapN) > 1;
go
  
-- 15. Hiển thị những đơn hàng không cần được xuất hóa đơn (nghĩa là cột Hóa đơn điện tử không có giá trị) 
select *
from DonDatHang_HoaDon 
where maHoaDonDienTu is null
go