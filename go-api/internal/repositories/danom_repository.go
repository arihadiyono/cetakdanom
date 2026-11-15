package repositories

import (
	"context"
	"database/sql"
	"fmt"
	"strings"

	"cetakdanom/api/internal/models"
)

type DanomRepository struct {
	db *sql.DB
}

func NewDanomRepository(db *sql.DB) *DanomRepository {
	return &DanomRepository{db: db}
}

// GetDanomList executes SIKAP_GET_DAFTARNOMINATIF_NAS_V2
func (r *DanomRepository) GetDanomList(
	ctx context.Context,
	kelurahanId string,
	batch string,
	projectId string,
	sort string,
	nopend string,
	idPetugas string,
	nippos string,
) (*models.DanomListResult, error) {
	if sort == "" {
		sort = "Nama"
	}
	if nopend == "" {
		nopend = "40000"
	}
	if idPetugas == "" {
		idPetugas = "demo"
	}
	if nippos == "" {
		nippos = "987654321"
	}

	query := `EXEC SIKAP_GET_DAFTARNOMINATIF_NAS_V2 
		@IDKELURAHAN=@p1, 
		@NOPEND=@p2, 
		@ID_PETUGAS=@p3, 
		@NIPPOS=@p4, 
		@OPT=@p5, 
		@BATCH=@p6, 
		@SORT=@p7, 
		@ID_PROJECT=@p8`

	rows, err := r.db.QueryContext(ctx, query,
		sql.Named("p1", kelurahanId),
		sql.Named("p2", nopend),
		sql.Named("p3", idPetugas),
		sql.Named("p4", nippos),
		sql.Named("p5", "0"),
		sql.Named("p6", batch),
		sql.Named("p7", sort),
		sql.Named("p8", projectId),
	)
	if err != nil {
		return nil, fmt.Errorf("error executing SIKAP_GET_DAFTARNOMINATIF_NAS_V2: %w", err)
	}
	defer rows.Close()

	var records []models.DanomRecipient
	var totalNominal float64

	for rows.Next() {
		var (
			idPelanggan, pelanggan, alamat, alamatKtp sql.NullString
			amount                                    sql.NullInt64
			kuantitas                                 sql.NullInt32
			total                                     sql.NullInt64
			idKel, kel, idKec, kec, idKab, kab        sql.NullString
			idProp, prop, idKprk, kprk, idKantor, kpc sql.NullString
			rowBatch, regional, nik                   sql.NullString
			bs1, bs2, msbayar, bs3                    sql.NullString
			statusGaruda, labelTahap, headerDanom     sql.NullString
			rw, rt, desil, percentile                 sql.NullString
		)

		err := rows.Scan(
			&idPelanggan, &pelanggan, &alamat, &alamatKtp, &amount, &kuantitas, &total,
			&idKel, &kel, &idKec, &kec, &idKab, &kab,
			&idProp, &prop, &idKprk, &kprk, &idKantor, &kpc,
			&rowBatch, &regional, &nik,
			&bs1, &bs2, &msbayar, &bs3,
			&statusGaruda, &labelTahap, &headerDanom,
			&rw, &rt, &desil, &percentile,
		)
		if err != nil {
			return nil, fmt.Errorf("error scanning danom row: %w", err)
		}

		item := models.DanomRecipient{
			IdPelanggan: strings.TrimSpace(idPelanggan.String),
			Nama:        strings.TrimSpace(pelanggan.String),
			Alamat:      strings.TrimSpace(alamat.String),
			AlamatKtp:   strings.TrimSpace(alamatKtp.String),
			Nominal:     float64(amount.Int64),
			Kuantitas:   int(kuantitas.Int32),
			Total:       float64(total.Int64),
			IdKelurahan: strings.TrimSpace(idKel.String),
			Kelurahan:   strings.TrimSpace(kel.String),
			IdKecamatan: strings.TrimSpace(idKec.String),
			Kecamatan:   strings.TrimSpace(kec.String),
			IdKabupaten: strings.TrimSpace(idKab.String),
			Kabupaten:   strings.TrimSpace(kab.String),
			IdProvinsi:  strings.TrimSpace(idProp.String),
			Provinsi:    strings.TrimSpace(prop.String),
			Kprk:        strings.TrimSpace(kprk.String),
			Kantor:      strings.TrimSpace(kpc.String),
			Batch:       strings.TrimSpace(rowBatch.String),
			Regional:    strings.TrimSpace(regional.String),
			Nik:         strings.TrimSpace(nik.String),
			Bs1:         strings.TrimSpace(bs1.String),
			Barcode1:    strings.TrimSpace(bs1.String),
			HeaderDanom: strings.TrimSpace(headerDanom.String),
			Rw:          strings.TrimSpace(rw.String),
			Rt:          strings.TrimSpace(rt.String),
			StatusDanom: "BelumCetak",
		}

		records = append(records, item)
		totalNominal += item.Nominal
	}

	return &models.DanomListResult{
		Records:      records,
		TotalKpm:     len(records),
		TotalNominal: totalNominal,
	}, nil
}

// InquiryNik retrieves one recipient record by NIK (for CDS Satuan)
func (r *DanomRepository) InquiryNik(ctx context.Context, nik string) (*models.CdsRecipientInquiry, error) {
	// Search in active table T_PENERIMA_SPK_MB1
	query := `SELECT TOP 1 
		ID_PELANGGAN, NIK, NAMA, ALAMAT_DTKS, 
		NMDESA_DTKS, NMKEC_DTKS, NMKAB_DTKS, NMPROP_DTKS, 
		NOMINAL
	FROM T_PENERIMA_SPK_MB1 
	WHERE NIK = @p1`

	var (
		idPelanggan, dbNik, nama, alamat sql.NullString
		desa, kec, kab, prop             sql.NullString
		nominal                          sql.NullFloat64
	)

	err := r.db.QueryRowContext(ctx, query, sql.Named("p1", nik)).Scan(
		&idPelanggan, &dbNik, &nama, &alamat,
		&desa, &kec, &kab, &prop,
		&nominal,
	)
	if err == sql.ErrNoRows {
		return nil, nil // not found
	}
	if err != nil {
		return nil, fmt.Errorf("error querying recipient by NIK: %w", err)
	}

	return &models.CdsRecipientInquiry{
		IdResponse:       "000",
		IdPelanggan:      strings.TrimSpace(idPelanggan.String),
		Nik:              strings.TrimSpace(dbNik.String),
		Nama:             strings.TrimSpace(nama.String),
		AlamatDtks:       strings.TrimSpace(alamat.String),
		NmDesaDtks:       strings.TrimSpace(desa.String),
		NmKecDtks:        strings.TrimSpace(kec.String),
		NmKabDtks:        strings.TrimSpace(kab.String),
		NmPropDtks:       strings.TrimSpace(prop.String),
		Nominal:          nominal.Float64,
		NoVoucher:        "VCH-" + strings.TrimSpace(dbNik.String),
		NamaPerusahaan:   "KEMENSOS RI",
		AlamatPerusahaan: "JAKARTA PUSAT",
	}, nil
}
