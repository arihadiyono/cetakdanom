package services

import (
	"context"

	"cetakdanom/api/internal/models"
	"cetakdanom/api/internal/repositories"
)

type AuthService struct {
	repo *repositories.AuthRepository
}

func NewAuthService(repo *repositories.AuthRepository) *AuthService {
	return &AuthService{repo: repo}
}

func (s *AuthService) Authenticate(ctx context.Context, username, password string) (*models.LoginResponse, error) {
	return s.repo.Authenticate(ctx, username, password)
}
