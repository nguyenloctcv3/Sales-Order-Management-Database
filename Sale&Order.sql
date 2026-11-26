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