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