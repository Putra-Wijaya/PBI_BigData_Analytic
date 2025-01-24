-- Membuat atau mengganti tabel bernama 'tabel_analisa' di dataset 'kimia_farma'
CREATE OR REPLACE TABLE teak-frame-448605-p4.kimia_farma.tabel_analisa AS
SELECT 
    -- Kolom transaksi
    t.transaction_id,                -- ID unik dari transaksi
    t.date,                          -- Tanggal transaksi
    t.customer_name,                 -- Nama pelanggan yang melakukan transaksi

    -- Kolom cabang
    b.branch_id,                     -- ID cabang tempat transaksi dilakukan
    b.branch_name,                   -- Nama cabang tempat transaksi dilakukan
    b.kota,                          -- Kota lokasi cabang
    b.provinsi,                      -- Provinsi lokasi cabang
    b.rating AS rating_cabang,       -- Rating cabang berdasarkan data dari tabel cabang

    -- Kolom produk
    p.product_id,                    -- ID unik produk yang terlibat dalam transaksi
    p.product_name,                  -- Nama produk
    p.product_category,              -- Kategori produk
    p.price AS actual_price,         -- Harga asli produk (sebelum diskon)

    -- Diskon
    t.discount_percentage,           -- Persentase diskon yang diterapkan pada transaksi

    -- Menghitung persentase laba kotor berdasarkan harga produk
    CASE 
        WHEN p.price <= 50000 THEN 0.1                 -- Jika harga produk <= 50.000, laba kotor adalah 10%
        WHEN p.price > 50000 AND p.price <= 100000 THEN 0.15 -- Jika harga antara 50.001-100.000, laba kotor adalah 15%
        WHEN p.price > 100000 AND p.price <= 300000 THEN 0.2  -- Jika harga antara 100.001-300.000, laba kotor adalah 20%
        WHEN p.price > 300000 AND p.price <= 500000 THEN 0.25 -- Jika harga antara 300.001-500.000, laba kotor adalah 25%
        ELSE 0.3                                      -- Jika harga > 500.000, laba kotor adalah 30%
    END AS persentase_gross_laba,

    -- Menghitung penjualan bersih (nett_sales) setelah diskon
    CAST(ROUND(t.price * (1 - t.discount_percentage)) AS INT64) AS nett_sales,

    -- Menghitung laba bersih (nett_profit) berdasarkan nett_sales dan persentase laba kotor
    CAST(ROUND(t.price * (1 - t.discount_percentage)) AS INT64) * 
    CASE
        WHEN p.price <= 50000 THEN 0.1                 -- Kondisi laba kotor berdasarkan harga produk
        WHEN p.price > 50000 AND p.price <= 100000 THEN 0.15
        WHEN p.price > 100000 AND p.price <= 300000 THEN 0.2
        WHEN p.price > 300000 AND p.price <= 500000 THEN 0.25
        ELSE 0.3
    END AS nett_profit,

    -- Rating transaksi
    t.rating AS rating_transaksi                       -- Rating yang diberikan pada transaksi

FROM
    -- Menggunakan tabel transaksi sebagai sumber data utama
    teak-frame-448605-p4.kimia_farma.kf_final_transaction t
JOIN
    -- Menggabungkan tabel transaksi dengan tabel cabang berdasarkan branch_id
    teak-frame-448605-p4.kimia_farma.kf_kantor_cabang b
ON
    t.branch_id = b.branch_id
JOIN
    -- Menggabungkan tabel transaksi dengan tabel produk berdasarkan product_id
    teak-frame-448605-p4.kimia_farma.kf_product p
ON
    t.product_id = p.product_id;
