package repositories

import (
	"context"
	"database/sql"
	"fmt"
	"strings"

	"cetakdanom/api/internal/models"
)

type ReferenceRepository struct {
	db *sql.DB
}

func NewReferenceRepository(db *sql.DB) *ReferenceRepository {
	return &ReferenceRepository{db: db}
}

// GetLayanan calls SIKAP_GET_Project_NAS
func (r *ReferenceRepository) GetLayanan(ctx context.Context) ([]models.LayananBansos, error) {
	rows, err := r.db.QueryContext(ctx, "EXEC SIKAP_GET_Project_NAS")
	if err != nil {
		return nil, fmt.Errorf("error executing SIKAP_GET_Project_NAS: %w", err)
	}
	defer rows.Close()

	var list []models.LayananBansos
	for rows.Next() {
		var item models.LayananBansos
		var header sql.NullString
		if err := rows.Scan(&item.Kode, &item.Nama, &header); err != nil {
			return nil, fmt.Errorf("error scanning project row: %w", err)
		}
		item.Kode = strings.TrimSpace(item.Kode)
		item.Nama = strings.TrimSpace(item.Nama)
		if header.Valid {
			item.HeaderDanom = strings.TrimSpace(header.String)
		}
		list = append(list, item)
	}

	return list, nil
}

// GetTahap calls SIKAP_GET_TAHAP_NAS with project id
func (r *ReferenceRepository) GetTahap(ctx context.Context, projectId string) ([]models.TahapBansos, error) {
	rows, err := r.db.QueryContext(ctx, "EXEC SIKAP_GET_TAHAP_NAS @IDPROJECT = @p1", sql.Named("p1", projectId))
	if err != nil {
		return nil, fmt.Errorf("error executing SIKAP_GET_TAHAP_NAS: %w", err)
	}
	defer rows.Close()

	var list []models.TahapBansos
	for rows.Next() {
		var idTahap, ketTahap sql.NullString
		if err := rows.Scan(&idTahap, &ketTahap); err != nil {
			return nil, fmt.Errorf("error scanning tahap row: %w", err)
		}
		b := strings.TrimSpace(idTahap.String)
		if b != "" {
			list = append(list, models.TahapBansos{Batch: b})
		}
	}

	return list, nil
}

// GetKabupaten calls SIKAP_GET_KABUPATEN
func (r *ReferenceRepository) GetKabupaten(ctx context.Context, nopend, idPetugas, nippos string) ([]models.WilayahKabupaten, error) {
	rows, err := r.db.QueryContext(ctx, 
		"EXEC SIKAP_GET_KABUPATEN @NOPEND=@p1, @ID_PETUGAS=@p2, @NIPPOS=@p3, @OPT=@p4",
		sql.Named("p1", nopend),
		sql.Named("p2", idPetugas),
		sql.Named("p3", nippos),
		sql.Named("p4", "0"),
	)
	if err != nil {
		return nil, fmt.Errorf("error executing SIKAP_GET_KABUPATEN: %w", err)
	}
	defer rows.Close()

	var list []models.WilayahKabupaten
	for rows.Next() {
		var raw string
		if err := rows.Scan(&raw); err != nil {
			return nil, fmt.Errorf("error scanning kabupaten row: %w", err)
		}
		parts := strings.Split(raw, "|")
		if len(parts) >= 2 {
			list = append(list, models.WilayahKabupaten{
				Kode: strings.TrimSpace(parts[0]),
				Nama: strings.TrimSpace(parts[1]),
			})
		}
	}

	return list, nil
}

// GetKecamatan calls SIKAP_GET_KECAMATAN
func (r *ReferenceRepository) GetKecamatan(ctx context.Context, kabId, nopend, idPetugas, nippos string) ([]models.WilayahKecamatan, error) {
	rows, err := r.db.QueryContext(ctx, 
		"EXEC SIKAP_GET_KECAMATAN @IDKECAMATAN=@p1, @NOPEND=@p2, @ID_PETUGAS=@p3, @NIPPOS=@p4, @OPT=@p5",
		sql.Named("p1", kabId),
		sql.Named("p2", nopend),
		sql.Named("p3", idPetugas),
		sql.Named("p4", nippos),
		sql.Named("p5", "0"),
	)
	if err != nil {
		return nil, fmt.Errorf("error executing SIKAP_GET_KECAMATAN: %w", err)
	}
	defer rows.Close()

	var list []models.WilayahKecamatan
	for rows.Next() {
		var raw string
		if err := rows.Scan(&raw); err != nil {
			return nil, fmt.Errorf("error scanning kecamatan row: %w", err)
		}
		parts := strings.Split(raw, "|")
		if len(parts) >= 2 {
			list = append(list, models.WilayahKecamatan{
				Kode:        strings.TrimSpace(parts[0]),
				Nama:        strings.TrimSpace(parts[1]),
				KabupatenId: kabId,
			})
		}
	}

	return list, nil
}

// GetKelurahan calls SIKAP_GET_KELURAHAN_BYKEC
func (r *ReferenceRepository) GetKelurahan(ctx context.Context, kecId, nopend, idPetugas, nippos string) ([]models.WilayahKelurahan, error) {
	rows, err := r.db.QueryContext(ctx, 
		"EXEC SIKAP_GET_KELURAHAN_BYKEC @IDKECAMATAN=@p1, @NOPEND=@p2, @ID_PETUGAS=@p3, @NIPPOS=@p4, @OPT=@p5",
		sql.Named("p1", kecId),
		sql.Named("p2", nopend),
		sql.Named("p3", idPetugas),
		sql.Named("p4", nippos),
		sql.Named("p5", "0"),
	)
	if err != nil {
		return nil, fmt.Errorf("error executing SIKAP_GET_KELURAHAN_BYKEC: %w", err)
	}
	defer rows.Close()

	var list []models.WilayahKelurahan
	for rows.Next() {
		var raw string
		if err := rows.Scan(&raw); err != nil {
			return nil, fmt.Errorf("error scanning kelurahan row: %w", err)
		}
		parts := strings.Split(raw, "|")
		if len(parts) >= 3 {
			list = append(list, models.WilayahKelurahan{
				Kode:          strings.TrimSpace(parts[0]),
				Nama:          strings.TrimSpace(parts[1]),
				KecamatanId:   kecId,
				KecamatanNama: strings.TrimSpace(parts[2]),
			})
		}
	}

	return list, nil
}
